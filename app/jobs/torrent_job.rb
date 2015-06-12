class TorrentJob < ActiveJob::Base
  def self.can_work_with_file_name?(link)
    false
  end

  def self.can_work_with_file?(file)
    file
  end
end