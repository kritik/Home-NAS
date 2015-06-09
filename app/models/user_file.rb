require "digest"
# What we should do:
# identify files and make snapshot of it as kde does it (async)
# async download for:
#  * magnet
#  * web
# states to started and ready files
# after file done and checksum changed, save binary diff
class UserFile < ActiveRecord::Base
  attr_accessor :temp_file
  belongs_to :folder
  belongs_to :user

  validates_presence_of   :folder_id#, :user_id
  validates_presence_of   :checksum, :extension, :file, unless: :pending?
  validates_uniqueness_of :file_name, scope: :folder_id
  after_validation :localize_file


  state_machine :initial => :local do
    state :pending    # state when need to fetch
    state :local      # on local machine
    state :processing # on image resized/preview on video
    state :completed  # all prepared
    state :uploaded   # is on the cloud

    event :local do
      transition :to => :local
    end

    event :process do
      transition :to => :processing
    end

    event :complete do
      transition [:local, :processing, :completed] => :completed
    end

    event :upload do
      transition [:completed, :uploaded] => :uploaded
    end
  end

  def dir
    Rails.root.join("public/system/user_files/#{folder.name}")
  end

  def path
    dir.join(file_name)
  end

  # accepts binary file
  def file= val
    self.state     = :local
    self.file_name = val.original_filename
    self.extension = File.extname(file_name)[1..-1]
    self.checksum  = Digest::SHA2.hexdigest(val.tempfile.read)
    @temp_file = val
  end
  def file; @temp_file; end

  # takes file from the string
  # if protocols are http ftp then curl/wget
  # if magnet then set to torrent
  # both are async
  def file_url= val
    return if val.blank?

    self.state = :pending
  end
  def file_url; end

  private
  def localize_file
    return if errors.any? || @temp_file.nil?

    FileUtils.mkdir_p(dir)
    FileUtils.copy_file(@temp_file.path, path)
  end
end
