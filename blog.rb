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
  property :author, String
  property :email, String
  property :title, String
  property :body, Text
end

DataMapper.repository(:comments) {
  Comment.auto_upgrade!
}

get "/" do
  @posts = Blog.all(:order => [:id.desc])
  erb :home, layout: :blog_template
end

get "/create" do
  # TODO: Add requirement for user authentication
  # TODO: Add form to add a blog title and body
  erb :create, layout: :blog_template
end

get "/view/:id" do |blog_id|
  @post = Blog.get(blog_id)
  # TODO: Display existing comments ordered from newest to oldest
  erb :view, layout: :blog_template
end

post "/view/comment/:id" do |post_id|
  DataMapper.repository(:comments) {
    Comment.create(
      blog_id: post_id,
      author: params[:name],
      email: params[:email],
      title: params[:title],
      body: params[:body]
    )
  }
  redirect back
end

get "/admin" do
  # TODO: Add requirement for user authentication
  # TODO: Add links to delete or edit blog posts
  erb :admin, layout: :blog_template
end

delete "/admin/delete/:id" do |blog_id|
  # TODO: Add requirement for user authentication
  # TODO: Delete the given blog post
  # TODO: Delete the associated comments
  redirect to("/admin")
end

patch "/admin/edit/:id" do |blog_id|
  # TODO: Add requirement for user authentication
  # TODO: allow the user to edit the title
  erb :admin_edit, layout: :blog_template
end