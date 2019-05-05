# frozen_string_literal: true

require 'fileutils'

namespace :file_storage do

  desc 'Copy over the migration needed to the application'
  task install: :environment do
    puts 'Copy over the migration needed to the application for using FileStorage.'

    migrate_dir = [__dir__, '..', '..', 'db', 'migrate'].join('/')
    src_file_for = ->(file) { "#{migrate_dir}/#{file}" }

    dest_dir = [Rails.root.to_s, 'db', 'migrate'].join('/')
    dest_file_for = ->(file) { "#{dest_dir}/#{file.gsub(/^\d*/, Time.zone.now.strftime('%Y%m%d%H%M%S'))}" }

    Dir.entries(migrate_dir).each do |file|
      FileUtils.cp(src_file_for.call(file), dest_file_for.call(file)) unless file.start_with?('.')
    end

    puts "Please run migrate. 'rails db:migrate' may works fine."
  end
end
