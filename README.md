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
