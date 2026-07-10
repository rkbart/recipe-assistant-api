class RecipeSuggestion < ApplicationRecord
  validates :prompt, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end