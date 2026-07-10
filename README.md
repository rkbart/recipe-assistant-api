# Recipe Assistant API

Rails JSON API for managing recipes, ingredients, and recipe ingredient amounts.

## Tech Stack

- Ruby on Rails 8.1 API mode
- SQLite
- Blueprinter for JSON serialization
- Pagy for recipe pagination
- Rack::Cors for browser access from the frontend
- RSpec, FactoryBot, and Shoulda Matchers for tests

## Setup

Install dependencies:

```bash
bundle install
```

Prepare the database:

```bash
bin/rails db:prepare
```

Run the API server:

```bash
bin/rails server
```

The API runs at `http://localhost:3000` by default.

## Testing

Run the full RSpec suite:

```bash
bundle exec rspec
```

## CORS

CORS is enabled for common local React development origins:

- `http://localhost:5173`
- `http://localhost:3000`

Override allowed origins with a comma-separated `CORS_ORIGINS` value:

```bash
CORS_ORIGINS=http://localhost:5173,http://localhost:4173 bin/rails server
```

## API Version

All public endpoints are under:

```text
/api/v1
```

## Error Format

Validation and not-found responses use a consistent `errors` array.

Validation error example:

```json
{
  "errors": [
    {
      "status": "422",
      "title": "Unprocessable content",
      "detail": "Title can't be blank",
      "source": {
        "attribute": "title"
      }
    }
  ]
}
```

Not found example:

```json
{
  "errors": [
    {
      "status": "404",
      "title": "Not found",
      "detail": "Recipe not found"
    }
  ]
}
```

## Recipes

Recipe JSON shape:

```json
{
  "id": 1,
  "title": "Pancakes",
  "instructions": "Mix and cook.",
  "servings": 4,
  "prep_time": 10,
  "cook_time": 15,
  "ingredients": [
    {
      "name": "Flour",
      "quantity": "2.0",
      "unit": "cups"
    }
  ]
}
```

### List Recipes

```http
GET /api/v1/recipes
```

Query parameters:

- `search`: filters by recipe title.
- `servings`: filters by exact servings count.
- `sort`: accepts `title`, `created_at`, or `servings`.
- `per_page`: page size from `1` to `100`; default is `10`.
- `page`: page number.

Example:

```bash
curl "http://localhost:3000/api/v1/recipes?search=chicken&sort=title&per_page=5"
```

Response:

```json
{
  "data": [
    {
      "id": 1,
      "title": "Chicken Salad",
      "instructions": "Mix ingredients.",
      "servings": 2,
      "prep_time": 15,
      "cook_time": 0,
      "ingredients": []
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 5,
    "total_pages": 1,
    "total_count": 1
  }
}
```

### Get Recipe

```http
GET /api/v1/recipes/:id
```

Example:

```bash
curl "http://localhost:3000/api/v1/recipes/1"
```

### Create Recipe

```http
POST /api/v1/recipes
```

Example:

```bash
curl -X POST "http://localhost:3000/api/v1/recipes" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe": {
      "title": "Omelette",
      "instructions": "Whisk, pour, and fold.",
      "servings": 2,
      "prep_time": 5,
      "cook_time": 8
    }
  }'
```

Accepted recipe fields:

- `title`
- `instructions`
- `servings`
- `prep_time`
- `cook_time`
- `ingredient_ids`

Note: `ingredient_ids` can associate existing ingredients, but the current API does not yet accept nested `quantity` and `unit` values when creating or updating recipes.

### Update Recipe

```http
PATCH /api/v1/recipes/:id
PUT /api/v1/recipes/:id
```

Example:

```bash
curl -X PATCH "http://localhost:3000/api/v1/recipes/1" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe": {
      "title": "Mushroom Omelette",
      "servings": 3
    }
  }'
```

### Delete Recipe

```http
DELETE /api/v1/recipes/:id
```

Example:

```bash
curl -X DELETE "http://localhost:3000/api/v1/recipes/1"
```

Returns `204 No Content` when successful.

## Ingredients

Ingredient JSON shape:

```json
{
  "id": 1,
  "name": "Flour"
}
```

### List Ingredients

```http
GET /api/v1/ingredients
```

Example:

```bash
curl "http://localhost:3000/api/v1/ingredients"
```

### Get Ingredient

```http
GET /api/v1/ingredients/:id
```

Example:

```bash
curl "http://localhost:3000/api/v1/ingredients/1"
```

### Create Ingredient

```http
POST /api/v1/ingredients
```

Example:

```bash
curl -X POST "http://localhost:3000/api/v1/ingredients" \
  -H "Content-Type: application/json" \
  -d '{
    "ingredient": {
      "name": "Sugar"
    }
  }'
```

### Update Ingredient

```http
PATCH /api/v1/ingredients/:id
PUT /api/v1/ingredients/:id
```

Example:

```bash
curl -X PATCH "http://localhost:3000/api/v1/ingredients/1" \
  -H "Content-Type: application/json" \
  -d '{
    "ingredient": {
      "name": "Brown Sugar"
    }
  }'
```

### Delete Ingredient

```http
DELETE /api/v1/ingredients/:id
```

Example:

```bash
curl -X DELETE "http://localhost:3000/api/v1/ingredients/1"
```

Returns `204 No Content` when successful.

## AI Recipe Suggestions

Generate recipe ideas using a local LLM (Ollama). The API accepts a text prompt and returns a structured recipe suggestion with title, instructions, ingredients, prep time, cook time, and servings.

### Prerequisites

Ollama must be running locally. Start it with Docker:

```bash
docker run -d --name ollama -p 11434:11434 ollama/ollama
```

The first time you request a suggestion, the `llama3.2` model (~2 GB) will be downloaded automatically. You can use a different model by setting the `OLLAMA_MODEL` environment variable.

### Configuration

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama server URL |
| `OLLAMA_MODEL` | `llama3.2` | Model name to use |

### Endpoints

#### Request a Recipe Suggestion

```http
POST /api/v1/ai/recipe_suggestions
```

Example:

```bash
curl -X POST "http://localhost:3000/api/v1/ai/recipe_suggestions" \
  -H "Content-Type: application/json" \
  -d '{
    "recipe_suggestion": {
      "prompt": "quick chicken dinner"
    }
  }'
```

Response:

```json
{
  "id": 1,
  "prompt": "quick chicken dinner",
  "status": "completed",
  "model_used": "llama3.2",
  "requested_at": "2026-07-09T09:37:30Z",
  "completed_at": "2026-07-09T09:37:50Z",
  "created_at": "2026-07-09T09:37:30Z",
  "response": {
    "title": "Quick Chicken Fajitas",
    "instructions": "Heat olive oil in a large skillet...",
    "ingredients": [
      { "name": "chicken breasts", "quantity": 1, "unit": "pounds" },
      { "name": "bell peppers", "quantity": 2, "unit": "cups" }
    ],
    "prep_time": 10,
    "cook_time": 20,
    "servings": 4
  }
}
```

The `status` field can be `pending`, `processing`, `completed`, or `failed`. Currently the request is processed synchronously and returns when complete. In production, the response returns immediately with `status: "pending"` and a background job processes the LLM call asynchronously.

#### Get a Suggestion

```http
GET /api/v1/ai/recipe_suggestions/:id
```

Example:

```bash
curl "http://localhost:3000/api/v1/ai/recipe_suggestions/1"
```

#### List Recent Suggestions

```http
GET /api/v1/ai/recipe_suggestions
```

Returns the last 20 suggestions ordered by most recent.

### How It Works

1. The controller creates a `RecipeSuggestion` record with `status: "pending"`.
2. The `Ai::RecipeSuggestionService` sends the user's prompt to Ollama's `/api/generate` endpoint with a system prompt that instructs the model to return structured JSON.
3. The raw LLM response is parsed, validated for required fields (`title`, `instructions`, `ingredients`), and stored as JSON in the `response` column.
4. If parsing fails, the suggestion is marked as `failed` with an error message.

### Background Jobs

The `Ai::RecipeSuggestionJob` is ready for async processing via Solid Queue. To enable it, replace the direct service call in the controller with:

```ruby
::Ai::RecipeSuggestionJob.perform_later(suggestion)
```

This is useful in production where LLM calls can take 10–30 seconds.

## Frontend Notes

For a React and TypeScript frontend, configure the API base URL as:

```text
http://localhost:3000/api/v1
```

Example fetch:

```ts
const response = await fetch("http://localhost:3000/api/v1/recipes");
const payload = await response.json();
```

Recipe list responses are wrapped in `data` and `pagination`. Single recipe and ingredient responses are returned as the resource object directly.

## Current Limitations

- Recipe create/update can attach existing ingredients by ID, but does not yet support nested recipe ingredient quantities and units.
- There is no authentication or authorization.
- Database constraints are still light; most validation currently lives in Rails models.
