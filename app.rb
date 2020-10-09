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

before '/mapsearch' do
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
  @contribute = Contribute.find_by(id: params[:id])
  erb :detail
end

get '/new' do
  @types = Type.all
  @prefectures = Prefecture.all
  if session[:lat].nil?
    @lat = nil
    @lng = nil
    @name = nil
  else
    @lat = session[:lat]
    @lng = session[:lng]
    @name = session[:name]
  end
  erb :new
end

post '/new' do
  if params[:image]
    image = params[:image][:tempfile]
    upload = Cloudinary::Uploader.upload(image.path)
    img_url = upload['url']
  end

  Contribute.create!(
    prefecture_id: params[:prefecture],
    type_id: params[:type],
    comment: params[:comment],
    user_id: current_user.id
  )
  Image.create!(
    image: img_url,
    contribute_id: Contribute.last.id
  )
  Place.create!(
    lat: session[:lat],
    lng: session[:lng],
    name: session[:name],
    contribute_id: Contribute.last.id
  )
  session[:lat] = nil
  session[:lng] = nil
  session[:name] = nil
  session[:place_id] = nil
  redirect '/'
end

post '/search' do
  name = params[:search]
  user = User.find_by(name: name)
  if user.nil?
    redirect '/'
  else
    id = user.id
    redirect "/home/#{id}"
  end
end

post '/mapsearch' do
  @types = Type.all
  @prefectures = Prefecture.all
  if params[:map_key] == ""
    redirect '/new'
  else
    searchPlace = params[:map_key]
    uri = URI("https://maps.googleapis.com/maps/api/place/textsearch/json")
    uri.query = URI.encode_www_form({
      language: "ja",
      query: searchPlace,
      key: "AIzaSyAjQu4tJW4hYSUAHBEZMXkLe7lqV8QB76M"
    })
    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)
    lat = json["results"][0]["geometry"]["location"]["lat"]
    lng = json["results"][0]["geometry"]["location"]["lng"]
    name = json["results"][0]["name"]
    place_id = json["results"][0]["place_id"]
    session[:lat] = lat
    session[:lng] = lng
    session[:name] = name
    session[:place_id] = place_id
    redirect '/new'
  end
end

get '/logout' do
  session[:user] = nil
  redirect '/signin'
end

get '/home/:id' do
  erb :home
end

get '/follow/:id' do
  @following_users = Follow.where(following_id: current_user.id)
  erb :follow
end

get '/follower/:id' do
  @followed_users = Follow.where(followed_id: current_user.id)
  erb :follower
end

get '/follow/add/:id' do
  Follow.create(
    following_id: current_user.id,
    followed_id: params[:id]
  )

  redirect '/'
end

get '/follow/delete/:id' do
  Follow.find_by(following_id: current_user.id, followed_id: params[:id]).delete
  redirect '/'
end