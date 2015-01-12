require "sinatra"
require "data_mapper"

use Rack::MethodOverride

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/blog.db")

class Blog
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :body, Text
end

Blog.auto_upgrade!

DataMapper.setup(:comments, "sqlite3://#{Dir.pwd}/comment.db")

class Comment
  include DataMapper::Resource

  property :id, Serial
  property :blog_id, Integer
  property :title, String
  property :body, Text
end

DataMapper.repository(:comments) {
  Comment.auto_upgrade!
}