class ExpertProfile < ApplicationRecord
  belongs_to :user
end

# class ExpertProfile < ApplicationRecord
#   belongs_to :user
#   validates :user, presence: true

#   # knowledge_base_links is stored as JSON in the DB; prefer a Hash in Ruby
#   after_initialize do
#     self.knowledge_base_links ||= {}
#   end
# end
