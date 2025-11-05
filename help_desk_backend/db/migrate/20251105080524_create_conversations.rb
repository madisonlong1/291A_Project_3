class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :title, null:false
      t.string :status, null:false, default: 'waiting'
      t.references :initiator_id, null:false, foreign_key:{to_table: :users}
      t.references :assigned_expert_id, foreign_key:{to_table: :users}
      t.datetime :last_message_at

      t.timestamps
    end
  end
end
