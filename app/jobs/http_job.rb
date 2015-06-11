require 'open-uri'
class HttpJob < ActiveJob::Base

  def self.can_work_with_file_name?(link)
    return true if link.starts_with?("http://") || link.starts_with?("https://") || link.starts_with?("ftp://") || link.starts_with?("sftp://")
    false
  end

  def perform(file)
    throw NotImplementedError.new("Cannot work with file") unless self.class.can_work_with_file_name?(file.server_data)

    obj = open(file.server_data)
    uf = ActionDispatch::Http::UploadedFile.new(tempfile: obj, filename: file.server_data.split("/").last, type: obj.content_type)

    file.file= uf
    file.save
  end
  # do chain for http:// .torrent
end