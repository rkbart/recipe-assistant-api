class ApplicationController < ActionController::API
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_validation_errors(record)
    render json: {
      errors: record.errors.map do |error|
        {
          status: "422",
          title: "Unprocessable content",
          detail: error.full_message,
          source: { attribute: error.attribute.to_s }
        }
      end
    }, status: :unprocessable_entity
  end

  def render_not_found(error)
    render json: {
      errors: [
        {
          status: "404",
          title: "Not found",
          detail: "#{error.model.demodulize} not found"
        }
      ]
    }, status: :not_found
  end
end
