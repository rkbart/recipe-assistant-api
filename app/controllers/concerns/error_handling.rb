module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_error
  end

  private

  def render_unprocessable_entity_error(exception)
    render json: {
      errors: [
        {
          status: "422",
          title: "Unprocessable content",
          detail: exception.message
        }
      ]
    }, status: :unprocessable_entity
  end
end