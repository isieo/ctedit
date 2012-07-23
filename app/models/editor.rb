class Editor < ActiveRecord::Base
  attr_accessible :contents, :filename, :settings
end
