# frozen_string_literal: true


class FileStorage::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/file_storage.rake'
  end
end
