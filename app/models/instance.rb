class Instance < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :protocol
end
