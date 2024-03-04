require 'sinatra/activerecord'
require './models.rb'
require 'dotenv'
Dotenv.load
require 'line/bot'
require './handle_message.rb'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

User.where.not(line_id: nil).each do |user|
    subscriptions = user.movies.select { |movie| movie.finish.present? }
    next if subscriptions.empty?

    message = create_flex_message(subscriptions, filter_finish_soon: true)
    greeting_message = {
      type: 'text',
      text: 'おはようございます、もうすぐ終了する映画をリマインドいたします。'
    }

    client.push_message(user.line_id, greeting_message)
    client.push_message(user.line_id, message)
end