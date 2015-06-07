class Folder < ActiveRecord::Base
  acts_as_nested_set
  has_many :files, class_name: UserFile
  validates :name, presence: true, allow_blank: true

  def title
    "/#{name.presence}"
  end
end
