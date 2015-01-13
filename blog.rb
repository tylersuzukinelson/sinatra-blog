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

enable :sessions

get "/" do
  @posts = Blog.all(:order => [:id.desc])
  erb :home, layout: :blog_template
end

post "/login" do
  if params[:username] == 'temp_auth' && params[:password] == 'oogaboogaboo'
    session[:my_session_id] = "durr"
    redirect back
  else
    redirect back
  end
end

get "/create" do
  if session[:my_session_id] == "durr"
    erb :create, layout: :blog_template
  else
    erb :login, layout: :blog_template
  end
end

post "/create" do
  Blog.create(
    title: params[:title],
    body: params[:body]
  )
  redirect to("/")
end

get "/view/:id" do |blog_id|
  @post = Blog.get(blog_id)
  DataMapper.repository(:comments) {
    @comments = Comment.all(blog_id: blog_id, order: [:id.desc])
  }
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
  if session[:my_session_id] == "durr"
    # TODO: Add links to delete or edit blog posts
    erb :admin, layout: :blog_template
  else
    erb :login, layout: :blog_template
  end
end

delete "/admin/delete/:id" do |blog_id|
  if session[:my_session_id] == "durr"
    # TODO: Delete the given blog post
    # TODO: Delete the associated comments
    redirect to("/admin")
  else
    erb :login, layout: :blog_template
  end
end

patch "/admin/edit/:id" do |blog_id|
  if session[:my_session_id] == "durr"
    # TODO: allow the user to edit the title
    erb :admin_edit, layout: :blog_template
  else
    erb :login, layout: :blog_template
  end
end