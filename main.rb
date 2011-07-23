require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'haml'
require 'dalli'
require 'time-ago-in-words'
require './user.rb'

set :cache, Dalli::Client.new

get '/' do
  if Sinatra::Application.environment.to_s == 'development'
    require "./spec/fixtures/user_data.rb"
    @users = USER_DATA.map {|user| User.new(user)}
  else
    @users = settings.cache.get('users')
  end

  if @users.nil?
    "No users found in cache."
  else
    @users = @users.sort_by { |k| k.updated_at }.reverse
    haml :index
  end
end