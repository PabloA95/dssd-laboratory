class Project < ApplicationRecord
  belongs_to :user
  has_many :instances
end
