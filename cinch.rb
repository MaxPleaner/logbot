require 'cinch'
require 'sqlite3'
require 'dm-sqlite-adapter'
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

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "__maxbot"
    c.channels = [
      "##codeunion",
      # "#appacad-sf-aug4-2014"
    ]
  end

  on :message, /^log.*/ do |m|
    content = m.message[4..-1]
    if content[0..1] == "t="
      topic = content[2..-1].split(" ")[0]
      content = content[(content.split(" ")[0].length+1)..-1]
    end
    Note.create(:user => m.user.nick, :content => content, :created_at => Time.now, :topic => topic)
    m.reply "Message from #{m.user} was logged - see it at maxbot.ngrok.com"
  end

  on :message, /^echo.*/ do |m|
    message = m.message.split("echo")[1]
    m.reply "#{m.user}said \"#{message}\""
  end

end
  
bot.start
