require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require 'dotenv/load'

require 'open-uri'
require 'net/http'
require 'json'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV['CLOUD_NAME']
    config.api_key = ENV['CLOUDINARY_API_KEY']
    config.api_secret = ENV['CLOUDINARY_API_SECRET']
  end
end

before '/' do
  if session[:user].nil?
    redirect '/signin'
  end
end

before '/detail/:id' do
  if session[:user].nil?
    redirect '/signin'
  end
end

before '/new' do
  if session[:user].nil?
    redirect '/signin'
  end
end

get '/' do
  erb :index
end

get '/signin' do
  erb :signin
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/signup' do
  erb :signup
end

post '/signup' do
  if params[:image]
    image = params[:image][:tempfile]
    upload = Cloudinary::Uploader.upload(image.path)
    img_url = upload['url']
  end

  @user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    image: img_url
  )

  session[:user] = @user.id
  redirect '/'
end

get '/detail/:id' do
  erb :detail
end

get '/new' do
  erb :new
end

post '/search' do
  key = params[:search]
end