require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require './scraping_on_screen.rb'
require './update_on_screen.rb'
# require './scraping_movie.rb'
Dotenv.load
enable :sessions

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def varidate_email(address)
  if address.match(/\A.+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/)
    return true
  else
    return false
  end
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
              replyes.push(subscription.title)
            end
            reply=replyes.join("\n")
            message.push({
              type: 'text',
              text: reply
            })
          else
            message.push({
              type: 'text',
              text: event.message['text']
            })
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
    @theater = User.find(session[:user]).my_theater
    # url='https://www.unitedcinemas.jp/'+@theater+'/daily.php'
    # @movies = Scraping_on_screen.load_schedule_data(url)
    # @movies.each do |movie|
    #   unless Movie.find_by(title: movie[0],theater: @theater)
    #   Movie.create(title: movie[0], movie_id: movie[1], theater: @theater)
    #   end
    #   if movie[2]
    #     Movie.find_by(title: movie[0]).update(finish: movie[2])
    #   end
    # end
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
    @theaters = Theater.all
    @theater = params[:theater]
    id = Movie.find_by(movie_id: params[:id], theater: @theater).id
    unless Subscription.find_by(user_id: session[:user], movie_id: id)
      Subscription.create(user_id: session[:user], movie_id: id, theater: @theater)
    end
  end
  @movies=[]
   todays = Today.all
    todays.each do |today|
      if today.theater == @theater
      row = [today.title, today.movie_id, today.finish, @theater]
      @movies.push(row)
      end
    end
    erb :index
end

post '/delete/:id' do
  if session[:user]
    theater = params[:theater]
    id = Movie.find_by(movie_id: params[:id], theater: theater).id
    Subscription.find_by(user_id: session[:user], movie_id: id).destroy
  end
  redirect '/mypage'
end

get '/mypage' do
  if session[:user]
    @my_movies = []
    subscriptions = User.find(session[:user]).movies
    subscriptions.each do |subscription|
     movie_param=[subscription.title, subscription.movie_id, subscription.theater, subscription.finish]
     @my_movies.append(movie_param)
    end
    erb :mypage
  else
    redirect '/'
  end
end

get '/signin' do
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

post '/signin' do
   user = User.find_by(mail: params[:mail])
   if user && user.authenticate(params[:password])
        session[:user] = user.id
   else
      redirect '/signin'
   end
   redirect '/'
end

post '/signup' do
  unless User.find_by(mail: params[:mail])
    @user = User.create(name: params[:name], mail: params[:mail], my_theater: params[:theater], password: params[:password], password_confirmation: params[:password_confirmation])
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/'
  else
    redirect '/signup'
  end
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end
