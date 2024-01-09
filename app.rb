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
          if event.message['text'] == '>登録した映画'
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
          elsif event.message['text'] == '>もうすぐ終了する映画'
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


get '/auth/line/callback' do
  auth_info = env['omniauth.auth']
  user_name = auth_info.info.name  
  user_id = auth_info.uid         
  profile_pic = auth_info.info.image

  user = User.find_by(line_id: user_id)
  if user
    user.update(line_name: user_name, line_icon_url: profile_pic)
  else
    user = User.create(line_id: user_id, line_name: user_name, line_icon_url: profile_pic)
    message = user_name + "様、初めまして。私Filmanagerと申します。これからよろしくお願い致します。\nご主人様が登録された映画の終了予定日が決まり次第毎朝お知らせ致します。"
    client.push_message(user_id, message)
  end
  
  session[:user] = user.line_id
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