class CreateRecipeSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :recipe_suggestions do |t|
      t.text :prompt, null: false
      t.text :response
      t.string :status, null: false, default: "pending"
      t.string :model_used
      t.datetime :requested_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :recipe_suggestions, :status
  end
end
