require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :contributes
  has_many :following, through: :follows
  has_many :followed, through: :follows
  validates :name, presence: true
  validates :password, presence: true
  validates :image, presence: true
end

class Follow < ActiveRecord::Base
  belongs_to :following, class_name: "User"
  belongs_to :followed, class_name: "User"
end

class Contribute < ActiveRecord::Base
  belongs_to :user
  belongs_to :prefecture
  belongs_to :type
  has_many :images, dependent: :destroy
  validates :comment, presence: true
end

class Prefecture < ActiveRecord::Base
  has_many :contributes
end

class Type < ActiveRecord::Base
  has_many :contributes
end

class Image < ActiveRecord::Base
  belongs_to :contribute
  validates :image, presence: true
end

class Place < ActiveRecord::Base
  belongs_to :contribute
end