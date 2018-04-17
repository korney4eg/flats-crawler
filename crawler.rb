#!/usr/bin/env ruby -w
# encoding: utf-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require './lib/connector-json.rb'
require './lib/flat-crawlers/tvoya-stolica.rb'
require 'logger'
require 'net/http'

def send_message(message)
  bot_token = ENV['BOT_TOKEN'] || 'unset'
  chat_id = ENV['CHAT_ID']|| 'unset'

  if bot_token != 'unset' and chat_id != 'unset'
    req = Net::HTTP.post_form(URI.parse("https://api.telegram.org/bot#{bot_token}/sendMessage"), {"parse_mode" => "markdown","chat_id" => chat_id,"text" => message})
#    puts req.body
  end
end

connection = JSONConnector.new('1.json')

ts = TSCrawler.new(connection)
ts.parse_flats
messages = ts.get_messages
message = ""
messages.each_key do |m_k|
  if messages[m_k].size > 0
    message += "*#{m_k}*\n"
    i = 0
    messages[m_k].each do |mes|
      message += "#{ mes }\n"
      i += 1
      if message.size > 4000
        send_message message
        message = ""
      end
    end
  end
end
if message.size > 0
  send_message message 
else
  send_message "No updates from *#{Socket.gethostname}*"
end


connection.close
