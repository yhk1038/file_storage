class Post < ApplicationRecord
  has_one_file :resume
  has_many_files :projects
end
