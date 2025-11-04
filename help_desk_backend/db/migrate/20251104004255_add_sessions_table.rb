class CreateUsers < ActiveRecord::Migration[8.1] # or [7.0] etc.
  def change
    create_table :users do |t|
      # Add these constraints
      t.string :username, null: false, index: { unique: true }
      t.string :password_digest, null: false
      
      t.datetime :last_active_at

      t.timestamps
    end
  end
end