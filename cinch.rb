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
    c.nick = "logbot"
    c.channels = [
      "##codeunion",
      "#appacad-sf-aug4-2014"
    ]
  end

  on :message, /^\!log.*/i do |m|
    content = m.message[5..-1]
    if content[0..1] == "t="
      topic = content[2..-1].split(" ")[0]
      content = content[(content.split(" ")[0].length+1)..-1]
    end
    Note.create(:user => m.user.nick, :content => content, :created_at => Time.now, :topic => topic)
    m.reply "Message from #{m.user} was logged - see it at logbot.ngrok.com"
  end

  on :message, /^\!echo.*/i do |m|
    message = m.message.split("echo ")[1]
    m.reply "#{m.user} said \"#{message}\""
  end

  on :message, /.*logbot.*/i do |m|
    unless m.message == "logbot help"
      m.reply "Did someone say my name? Type 'logbot help' for commands"
    end
  end

  on :message, "logbot help" do |m|
    m.reply "\n1. \"!echo\": any text following !echo will be echoed into the room.\n\n2. \"!log\": any text after !log will be saved to database (and viewable in the interface at logbot.ngrok.com). \nYou can specify a topic like so: \"log t=music mars volta is good\"\n Only single-word topics are currently valid.\nyour username is attached to the log.\ngithub.com/maxpleaner/logbot"
  end
end
  
bot.start
