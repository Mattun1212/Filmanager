require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

before do
  if Count.count == 0
    Count.create(number: 0, title: "一個目")
  end
end

get '/' do
  redirect '/count'
end

get '/count' do
  @numbers=Count.all.order("id desc")
  erb :index
end

post '/create' do
  Count.create(number: 0, title: params[:title])
  redirect '/count'
end

post '/edit/:id' do
  Count.find(params[:id]).update(title: params[:title])
  redirect '/count'
end

post '/delete/:id' do
  Count.destroy(params[:id])
  redirect '/count'
end

post '/plus/:id' do
  count = Count.find(params[:id])
  count.number = count.number + 1
  count.save
  redirect '/count'
end

post '/minus/:id' do
  count = Count.find(params[:id])
  count.number = count.number - 1
  count.save
  
  redirect '/count'
end

post '/multi/:id' do
  count = Count.find(params[:id])
  count.number = count.number * 2
  count.save
  redirect '/count'
end

post '/div/:id' do
  count = Count.find(params[:id])
  count.number = count.number / 2
  count.save
  redirect '/count'
end

post '/clear/:id' do
  count = Count.find(params[:id])
  count.number = 0
  count.save
  redirect '/count'
end