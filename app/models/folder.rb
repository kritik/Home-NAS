class Folder < ActiveRecord::Base
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
