# frozen_string_literal: true

require 'file_storage/attached/one'
require 'file_storage/attached/many'

module FileStorage

  module Attached::Macros
    def has_one_file(name = nil, location: :system)
      unless name
        raise NameError, "Attachment name key is not allowed for nil" \
                         "Make sure of using name key on class method 'has_one_file'"
      end
      name = name.to_s.to_sym

      class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}
              @file_storage_attached_#{name} ||= FileStorage::Attached::One.new('#{name}', self, location: '#{location}')
            end

            def #{name}=(attachable)
              #{name}.attach(attachable)
            end
      CODE

      has_one :"#{name}_file", -> { where(name: name) }, class_name: '::FileStorage::Attachment', as: :record, inverse_of: :record, dependent: :destroy
    end



    def has_many_files(name = nil, location: :system)
      unless name
        raise NameError, "Attachment name key is not allowed for nil" \
                         "Make sure of using name key on class method 'has_many_files'"
      end
      name = name.to_s.to_sym

      class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}
              @active_storage_attached_#{name} ||= FileStorage::Attached::Many.new("#{name}", self, location: '#{location}')
            end

            def #{name}=(attachables)
              #{name}.attach(attachables)
            end
      CODE

      has_many :"#{name}_files", -> { where(name: name) }, class_name: '::FileStorage::Attachment', as: :record, inverse_of: :record, dependent: false
    end
  end

end
