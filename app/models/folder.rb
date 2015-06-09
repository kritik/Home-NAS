class Folder < ActiveRecord::Base
  acts_as_nested_set
  has_many :files, class_name: "UserFile"
  validates :path, presence: true, allow_blank: true
  validates :path, uniqueness: true
  alias_attribute :name, :path

  def title
    "/#{path.presence}"
  end

  def root?
    path.blank?
  end
end
