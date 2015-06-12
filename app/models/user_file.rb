require "digest"
# What we should do:
# identify files and make snapshot of it as kde does it (async)
# async download for:
#  * magnet
#  * web
# states to started and ready files
# after file done and checksum changed, save binary diff
class UserFile < ActiveRecord::Base
  WORKER_LIST = [HttpJob]
  attr_accessor :temp_file, :file_last_action
  belongs_to :folder
  belongs_to :user

  validates_presence_of   :folder_id#, :user_id
  validates_presence_of   :checksum, :extension, :file, unless: :pending?
  validates_uniqueness_of :file_name, scope: :folder_id

  after_validation :localize_file
  after_save :run_processor


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
    Rails.root.join("public/system/user_files/#{folder.path}")
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
    @file_last_action = __method__.to_sym
  end
  def file; @temp_file; end

  # takes file from the string
  # if protocols are http ftp then curl/wget
  # if magnet then set to torrent
  # both are async
  def file_url= val
    return if val.blank?

    self.state       = :pending
    self.server_data = val
    @file_last_action = __method__.to_sym
  end
  def file_url; end

  private
  def localize_file
    return if errors.any? || @temp_file.nil?

    FileUtils.mkdir_p(dir)
    FileUtils.copy_file(@temp_file.path, path)
  end


  # some other job should decide what to do
  # in order to better support if errors occured
  def run_processor
    if @file_last_action == :file_url
      processor = WORKER_LIST.detect{|worker| worker.can_work_with_file_name?(val) }
      processor.perform_later(self)
    elsif @file_last_action == :file

    end

  end
end
