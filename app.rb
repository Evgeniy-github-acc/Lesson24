require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
	enable :sessions
end

helpers do
	def username
	  session[:identity] ? session[:identity] : 'Вход для Администрации'
	end
end

before '/secure/*' do
	unless session[:identity] == '123' && session[:password] == '123' 
	  session[:previous_url] = request.path
	  @error = 'Извините, просмотр служебной информации только для администрации'
	  halt erb(:login_form)
	end
 end

 get '/login/form' do
	erb :login_form
end

get '/secure/place' do
	@input = File.read './public/users.txt'
	erb '<%= @input %>'
end

post '/login/attempt' do
	session[:identity] = params['username']
	session[:password] = params['password']
	@pas = session[:password]
	@us = session[:identity]
	where_user_came_from = session[:previous_url] || '/'
	redirect to where_user_came_from
end



get '/logout' do
	session.delete(:identity)
	erb "<div class='alert alert-message'>Вы вышли</div>"
end



get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
	erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do
	@client = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	f = File.open './public/users.txt', 'a'
	f.write "Клиент: #{@client}, номер телефона: #{@phone}, время: #{@datetime}, мастер  #{@barber}\n"
	f.close
	@message = "Уважаемый #{@client}, #{@barber} будет ждать Вас #{@datetime}"
	@title = "Спасибо!"
	erb :message
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@client = params[:username]
	@email = params[:email]
	@mail = params[:mail]
	f = File.open './public/contacts.txt', 'a'
	f.write "Клиент: #{@client} \nЭлектронная почта: #{@email} \nСообщение: \n  #{@mail}\n ===================================================================================================\n\n\n"
	f.close
	@message = "Уважаемый #{@client}, благодарим за обратную связь! Ваше обращение будет обработано в ближайшее время!"
	@title = "Сообщение отправлено!"
	erb :message
end 


  