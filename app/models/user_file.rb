require "digest"
class UserFile < ActiveRecord::Base
  dragonfly_accessor :file
  belongs_to :folder
  belongs_to :user

  validates_presence_of   :folder_id, :checksum, :extension, :file#, :user_id
  validates_uniqueness_of :file_name, scope: :folder_id

  before_validation :set_extension
  before_validation :set_checksum

  def file= val
    @v_file = val.tempfile.read
    super
  end

  def move(target_folder)
    self.folder = target_folder
    save!
  end

  def set_extension
    self.extension = File.extname(file_name)[1..-1] if file_name.present?
  end

  def set_checksum
    self.checksum = Digest::SHA2.hexdigest(@v_file || file)
  end
end
