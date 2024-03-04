require './message_templates.rb'

def handle_message_event(client,event)
  if event.type == Line::Bot::Event::MessageType::Text
    case event.message['text']
    when '>登録した映画'
      subscriptions = User.find_by(line_id: event['source']['userId']).movies
      unless subscriptions.empty?
        message = create_flex_message(subscriptions)
      else
        message = {
        type: 'text',
        text: '現在登録されている映画は無いようです。'
        }
      end
      client.reply_message(event['replyToken'], message)
    when '>もうすぐ終了する映画'
      subscriptions = User.find_by(line_id: event['source']['userId']).movies
      unless subscriptions.empty?
        message = create_flex_message(subscriptions, filter_finish_soon: true)
      else
        message = {
        type: 'text',
        text: '現在終了予定日が決まっている映画は無いようです。'
        }
      end
      client.reply_message(event['replyToken'], message)
    end
  end
end

def handle_postback_event(client,event)
  data = Rack::Utils.parse_query(event['postback']['data'])
  case data['action']
  when 'delete'
    movie_id = data['movie_id']
    confirmation_message = create_confirmation_message(movie_id)
    client.reply_message(event['replyToken'], confirmation_message)
  when 'confirm_delete'
    user = User.find_by(line_id: event['source']['userId'])
    movie_id = data['movie_id']
    if user && movie_id
      subscription = Subscription.find_by(user_id: user.id, movie_id: movie_id)
      subscription.destroy if subscription
      reply_message = {
        type: 'text',
        text: "映画を削除しました。"
      }
      client.reply_message(event['replyToken'], reply_message)
    end
  when 'cancel_delete'
    reply_message = {
      type: 'text',
      text: "削除をキャンセルしました。"
    }
    client.reply_message(event['replyToken'], reply_message)
  end
end
