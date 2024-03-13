require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require './scraping_on_screen.rb'
require './update_on_screen.rb'
require './handle_message.rb'

Dotenv.load

set :sessions, true

#CSRFトークンを生成しsessionに保存
before do
  session[:csrf] ||= SecureRandom.hex(64)
end

#LINEログイン使用のためOmniAuthを設定
use OmniAuth::Builder do
  provider :line, ENV["LINE_CHANNEL_LOGIN_ID"], ENV["LINE_CHANNEL_LOGIN_SECRET"]
end

#LINE Bot APIクライアントの定義
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

#LINEからのコールバック時の処理
post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message #メッセージ受信時
      handle_message_event(client, event)
    when Line::Bot::Event::Postback #返信の受信時
      handle_postback_event(client, event)
    end
  end
  "OK"
end

#サインインページ表示
get '/signin'do
  unless session[:user]
   erb :sign_in
  else
    redirect '/'
  end
end

#サインアウト処理
get '/signout' do
  session.delete(:user)
  redirect '/'
end

#LINEログインのコールバック処理 LINEアカウントの情報からユーザ登録(id,名前,プロフ写真URL)
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
  end
  
  session[:user] = user.line_id
  if user.my_theater == nil
    redirect to('/mytheater')
  else
    redirect to('/')
  end
end

#LINEログイン失敗処理
get '/auth/failure' do
  @reason = params['message'] || "不明なエラー"
  erb :failure
end

#マイシアターの登録
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

#マイシアター登録に伴いユーザ登録完了後のメッセージ送信
post '/mytheater' do
  user = User.find_by(line_id: session[:user])
  user.update_columns(my_theater: params['mytheater'])
  message = user_name + "様、初めまして。私Filmanagerと申します。これからよろしくお願い致します。\nご主人様が登録された映画の終了予定日が決まり次第毎朝お知らせ致します。"
  client.push_message(user.line_id, message)
  redirect to('/')
end

#ルートパス
get '/' do
  unless session[:user] 
    erb :top # ログイン時トップページを表示
  else
    #ユーザの映画の登録状況を取得・反映してマイシアターで上映中の映画の一覧表示
    @theaters = Theater.all
    @theater = session[:selected_theater] || User.find_by(line_id: session[:user]).my_theater
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

#別の映画館の上映状況閲覧時の処理 ()
post '/index' do
  @theaters = Theater.all
  @theater = params[:theater]
  session[:selected_theater] = @theater
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

#映画登録時の処理
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
  redirect "/?theater=#{session[:selected_theater]}"
end

#映画の登録を削除する処理
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
    redirect "/?theater=#{session[:selected_theater]}"
  end
end

#マイページ表示
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