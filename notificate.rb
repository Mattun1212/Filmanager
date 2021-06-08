require './models.rb'
Dotenv.load
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

users=User.all
users.each do |user|
    if user.line_id.present?
        user_id = user.line_id
        subscriptions=User.find_by(line_id).movies
        subscriptions.each do |subscription|
         if subscription.finish.present?
            finish=subscription.finish+'終了'
            theater='('+subscription.theater+')'
            content = subscription.title+theater+finish
            message = {
                        type: 'text',
                        text: content+'の公開終了時期が迫っています！！'
                      }
            client.push_message(user_id, message)
         end
        end
    end
end