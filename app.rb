require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require './scraping_on_screen.rb'
require './update_on_screen.rb'

Dotenv.load

set :sessions, true
before do
  session[:csrf] ||= SecureRandom.hex(64)
end


use OmniAuth::Builder do
  provider :line, ENV["LINE_CHANNEL_LOGIN_ID"], ENV["LINE_CHANNEL_LOGIN_SECRET"]
end


def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

# def varidate_email(address)
#   if address.match(/\A.+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/)
#     return true
#   else
#     return false
#   end
# end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body)
  events.each do |event|
    userId = event['source']['userId']
    if event.is_a?(Line::Bot::Event::Message)
      if event.type === Line::Bot::Event::MessageType::Text
        message=[]
        uid=User.find_by(line_id: event['source']['userId'])
        if uid.nil?
         if varidate_email(event.message['text'])
          user=User.find_by(mail: event.message['text'])
          if user.nil?
            message.push({
            type: 'text',
            text: 'ユーザが見つけられませんでした'
            })
          else
           User.find_by(mail: event.message['text']).update_columns(line_id: userId)
            message.push({
              type: 'text',
              text: user.name+'さん、よろしくお願いします。'
            })
          end
         else
          message.push({
            type: 'text',
            text: 'メールアドレスを入力してください'
          })
         end
        else
          if event.message['text'] == '登録した映画'
            replyes=[]
            subscriptions = User.find_by(line_id: userId).movies
            subscriptions.each do |subscription|
              theater='('+ Theater.find_by(name: subscription.theater).official+')'
              content = subscription.title.strip+theater
              replyes.push(content)
            end
            reply=replyes.join("\n")
            message.push({
              type: 'text',
              text: reply
            })
          elsif event.message['text'] == 'もうすぐ終了する映画'
            replyes=[]
            subscriptions=User.find_by(line_id: userId).movies
            subscriptions.each do |subscription|
              if subscription.finish.present?
                finish=subscription.finish.month.to_s+'/'+subscription.finish.day.to_s+'終了'
                theater='('+ Theater.find_by(name: subscription.theater).official+')'
                content = subscription.title.strip+theater+finish
                replyes.push(content)
              end
            end
            reply=replyes.join("\n")
            message.push({
              type: 'text',
              text: reply
            })
          else
            user=User.find_by(mail: event.message['text'])
            if user.present?
              message.push({
               type: 'text',
               text: 'こんにちは'+user.name+'さん'
              })
            else 
              message.push({
               type: 'text',
               text: 'まずは私に登録したメールアドレスを教えてください。'
              })
            end
          end
        end
        client.reply_message(event['replyToken'], message)
      end
    end
  end
  "OK"
end

get '/' do
  unless session[:user] 
    erb :top
  else
    @theaters = Theater.all
    @theater = User.find_by(line_id: session[:user]).my_theater
    subscriptions = User.find_by(line_id: session[:user]).movies
    @movies=[]
    todays = Today.all
    todays.each do |today|
      if today.theater == @theater
        row = [today.title, today.movie_id, today.finish, today.theater, today.img]
        subscriptions.each do |subscription|
          if  subscription.title == today.title && subscription.theater == today.theater
            row[5] = 'checked'
          end
        end
        @movies.push(row)
      end
    end
    erb :index
  end
end


post '/index' do
  @theaters = Theater.all
  @theater = params[:theater]
  @movies=[]
  todays = Today.all
  todays.each do |today|
      if today.theater == @theater
       row = [today.title, today.movie_id, today.finish, @theater, today.img]
       @movies.push(row)
      end
  end
  erb :index
end

get '/movie/:id' do
   url='https://www.unitedcinemas.jp/all/film.php?film='+params[:id]
   @movies = Scraping_movie.load_movie_data(url)
   erb :movie
end

post '/add/:id' do
  if session[:user]
    user = User.find_by(line_id: session[:user])
    @theaters = Theater.all
    @theater = params[:theater]
    id = Movie.find_by(movie_id: params[:id], theater: @theater).id
    unless Subscription.find_by(user_id: user.id, movie_id: id)
      Subscription.create(user_id: user.id, movie_id: id, theater: @theater)
    end
  end
  redirect '/'
end

post '/delete/:id' do
  if session[:user]
    user = User.find_by(line_id: session[:user])
    theater = params[:theater]
    id = Movie.find_by(movie_id: params[:id], theater: theater).id
    Subscription.find_by(user_id: user.id, movie_id: id).destroy
  end
  if params[:page] == "mypage"
    redirect '/mypage'
  else
    redirect '/'
  end
end

get '/mypage' do
  if session[:user]
    @my_movies = []
    subscriptions = User.find_by(line_id: session[:user]).movies
    subscriptions.each do |subscription|
     movie_param=[subscription.title, subscription.movie_id, subscription.theater, subscription.finish, subscription.img]
     @my_movies.append(movie_param)
    end
    erb :mypage
  else
    redirect '/'
  end
end

get '/signin'do
  unless session[:user]
   erb :sign_in
  else
    redirect '/'
  end
end

get '/signup' do
  unless session[:user]
   @theaters = Theater.all
   erb :sign_up
  else
    redirect '/'
  end
end

# post '/signin' do
#   user = User.find_by(mail: params[:mail])
#   if user && user.authenticate(params[:password])
#         session[:user] = user.id
#         redirect '/'
#   end
#   @miss="メールアドレスかパスワードに誤りがあります"
#   erb :sign_in
# end

# post '/signup' do
#   @theaters = Theater.all
#   unless User.find_by(mail: params[:mail])
#     @user = User.create(name: params[:name], mail: params[:mail], my_theater: params[:theater], password: params[:password], password_confirmation: params[:password_confirmation])
#     if @user.persisted?
#         session[:user] = @user.id
#         redirect '/'
#     end
    
#       if params[:password] == params[:password_confirmation]
#         @miss="不適切なパスワードです"
#       else 
#         @miss="パスワードが一致していません"
#       end
      
#       pattern = /\A.+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/
#       matched = params[:mail].match(pattern)
#       unless matched
#         @miss="メールアドレスが正しくありません"
#       end
      
#       erb :sign_up
#   else
#     @miss="すでに登録されたメールアドレスです"
#     erb :sign_up
#   end
# end

get '/auth/line/callback' do
  auth_info = env['omniauth.auth']

  # ユーザー情報の取得（例: ユーザー名、ユーザーID、プロフィール画像URL）
  user_name = auth_info.info.name  # LINEのユーザー名
  user_id = auth_info.uid          # LINEのユーザーID
  profile_pic = auth_info.info.image # プロフィール画像のURL

  # ユーザーデータベースの検索または新規作成
  user = User.find_or_create_by(line_id: user_id) do |u|
    u.line_name = user_name
    u.line_icon_url = profile_pic
  end
  
  # セッションにユーザーIDを保存
  session[:user] = user.line_id
  # ユーザーをホームページにリダイレクト
  if user.my_theater == nil
    redirect to('/mytheater')
  else
    redirect to('/')
  end
end

get '/auth/failure' do
  @reason = params['message'] || "不明なエラー"
  erb :failure
end

get '/mytheater' do
  if session[:user]
    user = User.find_by(line_id: session[:user])
    unless user.my_theater
      @theaters = Theater.all
      erb :my_theater
    else
      redirect to('/')
    end
  else
    redirect to('/')
  end
end

post '/mytheater' do
  user = User.find_by(line_id: session[:user])
  user.update_columns(my_theater: params['mytheater'])
  redirect to('/')
end

get '/signout' do
  session.delete(:user)
  redirect '/'
end
