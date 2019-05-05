# frozen_string_literal: true

module FileStorage
  class Attachment < ActiveRecord::Base
    self.table_name = 'file_storage_attachments'
    enum location: %w[system localhost amazone google]

    belongs_to :record, polymorphic: true, touch: true

    scope :on, ->(name) { where(name: name) }

    validates_presence_of :name, :record

    def self_group
      self.class.where(group_definition).order(sort_index: :asc)
    end

    def url
      case location
      when 'system'
        filepath.gsub(rails_public, '')
      end
    end

    def file
      @file ||= File.new(filepath, 'r')
    end

    def purge
      File.delete(filepath) if File.exist?(filepath)
      recursive_remove_dir
    end

    protected

    def group_definition
      { name: name, record_type: record_type }
    end

    private

    def recursive_remove_dir
      Dir["public/file_storage/#{record_type}/#{record_id}/**/*"]                        \
        .select { |d| File.directory? d }                    \
        .select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } \
        .each   { |d| Dir.rmdir d }
    end

    def rails_public
      Rails.root.join('public').to_s
    end
  end
end
