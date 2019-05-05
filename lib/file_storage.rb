# frozen_string_literal: true

require 'rails'

require 'active_record'
require 'active_support'
require 'active_support/rails'

require 'file_storage/version'
require 'file_storage/railtie' if defined?(Rails)

module FileStorage
  extend ActiveSupport::Autoload

  class Error < StandardError; end

  autoload :Attached

  def self.load!(config)
    require 'file_storage/attached'

    ActiveSupport.on_load(:active_record) do
      extend FileStorage::Attached::Macros
      load 'file_storage/attachment'
    end
  end
end
