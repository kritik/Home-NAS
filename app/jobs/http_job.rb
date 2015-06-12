require 'open-uri'
class HttpJob < ActiveJob::Base

  def self.can_work_with_file_name?(link)
    return true if link.starts_with?("http://") || link.starts_with?("https://") || link.starts_with?("ftp://") || link.starts_with?("sftp://")
    false
  end

  def self.can_work_with_file?(file)
    false
  end

  def perform(file)
    throw NotImplementedError.new("Cannot work with file") unless self.class.can_work_with_file_name?(file.server_data)

    obj = open(file.server_data)
    if obj.is_a?(StringIO)
      filename = obj.meta["content-disposition"].split("filename=\"").last[0..-2]
      temp = Tempfile.new(filename)
      temp.binmode
      temp.write(obj.read)
      uf = ActionDispatch::Http::UploadedFile.new(tempfile: temp, filename: filename, type: obj.content_type)
      file.server_data = obj.meta.to_json
      file.file= uf
      file.save!
    elsif obj.is_a?(Tempfile)
      uf = ActionDispatch::Http::UploadedFile.new(tempfile: obj, filename: file.server_data.split("/").last, type: obj.content_type)
      file.server_data = nil
      file.file= uf
      file.save!
    else
      throw NotImplementedError
    end
  end

  # do chain for http:// .torrent
end