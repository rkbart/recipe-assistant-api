class Recipe < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :title, presence: true
  validates :servings, numericality: { greater_than: 0 }

  scope :search, ->(term) {
    where("title LIKE ?", "%#{term}%") if term.present?
  }

  scope :by_servings, ->(servings) {
    where(servings: servings) if servings.present?
  }

  scope :sorted, ->(column) {
    allowed = %w[title created_at servings]

    if allowed.include?(column)
      order(column => :asc)
    else
      order(created_at: :desc)
    end
  }
end
