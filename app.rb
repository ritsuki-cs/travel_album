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

get '/' do
  erb :index
end