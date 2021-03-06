class GroupUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates :user_id, presence: true
  validates :group_id, presence: true, uniqueness: { scope: [:user_id] }
end
