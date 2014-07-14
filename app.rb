require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite:cinch.db")

class Note
  include DataMapper::Resource
  property :id, Serial
  property :content, String
  property :user, Text
  property :created_at, DateTime
  property :topic, Text
end

DataMapper.finalize
DataMapper.auto_upgrade!

get "/" do
  erb :home
end

get '/all' do
  @notes = Note.all
  erb :all
end

get '/users' do
  @users = []
  Note.all.each do |n|
    unless @users.include? n.user
      @users.push(n.user)
    end
  end
  erb :users
end

get '/user/:name' do |name|
  @user = name
  @notes = Note.all(:user => name)
  erb :user
end

get '/topics' do 
  @topics = []
  Note.all.each do |n|
    unless @topics.include? n.topic
      @topics.push(n.topic)
    end
  end
  erb :topics
end

get '/topic/:topic' do |topic|
  @topic = topic
  @notes = Note.all(:topic => topic)
  erb :topic
end
