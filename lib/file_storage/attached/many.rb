# frozen_string_literal: true

module FileStorage
  # Decorated proxy object representing of multiple attachments to a model.
  class Attached::Many < Attached
    delegate_missing_to :attachments

    # Returns all the associated attachment records.
    #
    # All methods called on this proxy object that aren't listed here will automatically be delegated to +attachments+.
    def attachments
      record.public_send("#{name}_files")
    end

    # Associates one or several attachments with the current record, saving them to the database.
    #
    #   document.images.attach(params[:images]) # Array of ActionDispatch::Http::UploadedFile objects
    #   document.images.attach(params[:signed_blob_id]) # Signed reference to blob from direct upload
    #   document.images.attach(io: File.open("/path/to/racecar.jpg"), filename: "racecar.jpg", content_type: "image/jpg")
    #   document.images.attach([ first_blob, second_blob ])
    def attach(*attachables)
      attachables.flatten.collect do |attachable|
        if record.new_record?
          attachments.build(build_attachment(attachable))
        else
          attachments.create!(build_attachment(attachable))
        end

        create_file_from(attachable)
      end
    end

    # Returns true if any attachments has been made.
    #
    #   class Gallery < ActiveRecord::Base
    #     has_many_attached :photos
    #   end
    #
    #   Gallery.new.photos.attached? # => false
    def attached?
      attachments.any?
    end

    # Deletes associated attachments without purging them, leaving their respective blobs in place.
    def detach
      if attached?
        attachments.destroy_all
      end
    end

    ##
    # :method: purge
    #
    # Directly purges each associated attachment (i.e. destroys the blobs and
    # attachments and deletes the files on the service).
    def purge
      if attached?
        attachments.each(&:purge)
        detach
      end
    end


    ##
    # :method: purge_later
    #
    # Purges each associated attachment through the queuing system.

    def build_attachment(attachable)
      {
        name: name,
        record: record,

        # blob: blob,
        location: location,
        namespace: namespace,

        original_filename: attachable.original_filename,
        filename: attachable.original_filename,
        filepath: store_path(attachable)
      }
    end

    def write_attachments(attachments)
      record.public_send("#{name}_files=", attachments)
    end
  end
end
