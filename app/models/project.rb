class Project < ActiveRecord::Base
  has_many :assign_logs, :dependent => :destroy
  has_many :developers, through: :assign_logs
  belongs_to :version_repository
  belongs_to :ticket_repository
  belongs_to :user

  validates :name, presence: true
end
