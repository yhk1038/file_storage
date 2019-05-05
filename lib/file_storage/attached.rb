# frozen_string_literal: true

require 'fileutils'
require 'action_dispatch'
require 'action_dispatch/http/upload'
require 'active_support/core_ext/module/delegation'

module FileStorage
  # Abstract base class for the concrete FileStorage::Attached::One and FileStorage::Attached::Many
  class Attached
    attr_reader :name, :record, :location

    def initialize(name, record, location:)
      @name = name
      @record = record
      @location = location
    end

    private

    # => original: create_blob_from(attachable)
    #
    # case attachable
    # when ActiveStorage::Blob
    #   attachable
    # when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
    #   ActiveStorage::Blob.create_after_upload! \
    #     io: attachable.open,
    #     filename: attachable.original_filename,
    #     content_type: attachable.content_type
    # when Hash
    #   ActiveStorage::Blob.create_after_upload!(attachable)
    # when String
    #   ActiveStorage::Blob.find_signed(attachable)
    # else
    #   nil
    # end
    def create_file_from(attachable)
      case attachable
      when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
        begin
          write_file_from attachable, path: store_path(attachable)
          read_file_from path: store_path(attachable)
        rescue IOError => e
          raise e
        end
      end
    end

    def write_file_from(attachable, path:)
      dir_path = File.dirname(path)
      FileUtils.mkpath(dir_path) unless Dir.exist?(dir_path)
      File.open(path, 'wb') { |file| file.write(attachable.read) }
    end

    def read_file_from(path:)
      File.new(path, 'r')
    end

    def read_file(attachable)
      read_file_from path: store_path(attachable)
    end

    def store_path(attachable)
      Rails.root.join('public', 'file_storage', namespace, attachable.original_filename)
    end

    def namespace
      if record.respond_to? 'namespace'
        record.namespace
      else
        t = Time.zone.now.strftime('%F-%H%M')
        [record.class.name.underscore, name, t].join('/')
      end
    end
  end
end

require 'file_storage/attached/one'
require 'file_storage/attached/many'
require 'file_storage/attached/macros'
