require "net/http"
require "uri"
require "json"

module Ai
  class RecipeSuggestionService
    OLLAMA_BASE_URL = ENV.fetch("OLLAMA_BASE_URL", "http://localhost:11434")
    DEFAULT_MODEL = ENV.fetch("OLLAMA_MODEL", "llama3.2")

    SYSTEM_PROMPT = <<~PROMPT.freeze
      You are a professional chef and recipe creator. Given a user's request, suggest a recipe.
      Respond ONLY with a single valid JSON object. No markdown, no code fences, no extra text before or after the JSON.
      Use this exact format (replace values as appropriate):
      {"title":"Recipe Name","instructions":"Step-by-step cooking instructions...","ingredients":[{"name":"ingredient name","quantity":1.5,"unit":"cups"}],"prep_time":15,"cook_time":30,"servings":4}
      Rules:
      - All string values must use double quotes
      - No trailing commas in arrays or objects
      - quantities must be numbers (not strings)
      - prep_time and cook_time are integers (minutes)
      - Ingredients should have name (string), quantity (number), unit (string)
      If the user's request is unclear or impossible, respond with:
      {"error":"Could not generate a recipe based on that request."}
    PROMPT

    def initialize(recipe_suggestion)
      @recipe_suggestion = recipe_suggestion
      @model = DEFAULT_MODEL
    end

    def call
      @recipe_suggestion.update!(status: "processing", model_used: @model, requested_at: Time.current)

      response = query_ollama(@recipe_suggestion.prompt)
      parsed = parse_response(response)

      @recipe_suggestion.update!(
        response: parsed.to_json,
        status: "completed",
        completed_at: Time.current
      )
    rescue StandardError => e
      @recipe_suggestion.update!(
        status: "failed",
        response: { error: e.message }.to_json,
        completed_at: Time.current
      )
      raise
    end

    private

    def query_ollama(prompt)
      uri = URI("#{OLLAMA_BASE_URL}/api/generate")
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 60
      http.read_timeout = 120

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = {
        model: @model,
        prompt: "#{SYSTEM_PROMPT}\n\nUser request: #{prompt}",
        stream: false,
        options: {
          temperature: 0.7,
          num_predict: 2048
        }
      }.to_json

      response = http.request(request)

      unless response.is_a?(Net::HTTPOK)
        raise "Ollama API error: #{response.code} - #{response.body}"
      end

      JSON.parse(response.body).dig("response")
    end

    def parse_response(raw_response)
      # Try to extract JSON from the response
      json_match = raw_response.match(/\{.*\}/m)
      raise "No valid JSON found in LLM response" unless json_match

      json_str = json_match[0]

      # Attempt to clean up common JSON formatting issues
      # Remove trailing commas before closing braces/brackets
      json_str = json_str.gsub(/,\s*([}\]])/, '\1')

      parsed = JSON.parse(json_str)
      return parsed if parsed.key?("error")

      # Validate required fields
      required = %w[title instructions ingredients]
      missing = required.select { |f| parsed[f].blank? }
      raise "Missing required fields: #{missing.join(', ')}" if missing.any?

      parsed
    end
  end
end