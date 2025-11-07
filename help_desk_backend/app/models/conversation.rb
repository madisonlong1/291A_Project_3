class Conversation < ApplicationRecord
  belongs_to :initiator, class_name: 'User', foreign_key: 'initiator_id'
  belongs_to :assigned_expert, class_name: 'User', foreign_key: 'assigned_expert_id', optional: true
  has_many :messages, dependent: :destroy
  has_many :expert_assignments, dependent: :destroy

  validates :title, presence: true
end
