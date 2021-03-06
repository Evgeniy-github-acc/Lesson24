require 'rubygems'
require 'sqlite3'
require 'bundler/setup'
require 'pony'
require 'sinatra'
require 'sinatra/reloader'



def get_db
	db = SQLite3::Database.new './public/barbershop.db'
	db.results_as_hash = true
	return db
end

configure do
	enable :sessions
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS "Users"
	(
		"Id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"Name" TEXT,
		"Phone" TEXT,
		"DateStamp" TEXT,
		"Barber" TEXT,
		"Color" TEXT
	)'
		
	
	db.execute 'CREATE TABLE IF NOT EXISTS "Barbers"
	(
		"Id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"Name" TEXT UNIQUE
	)'
	
#	db.close
	barbers = ["Walter White", 'Jessie Pinkman', 'Gus Fring', 'Иван Петров', 'Fredie', 'Анна Васильева']

	barbers.each do |i|
		db.execute "INSERT INTO Barbers(Name) 
				SELECT  '#{i}' 
				WHERE NOT EXISTS(SELECT Name FROM Barbers WHERE Name = '#{i}'
				)"
	end
	

end

helpers do
	def username
		if   session[:identity] == 'admin' && session[:password] == 'secret'
			"Вход выполнен"
		else
			"Выполните вход"
		end	
end

before '/secure/*' do
	unless session[:identity] == 'admin' && session[:password] == 'secret' 
	  session[:previous_url] = request.path
	  @error = 'Извините, просмотр служебной информации только для администрации'
	  halt erb(:login_form)
	end
 end

 get '/login/form' do
	erb :login_form
end

get '/secure/place' do
	db = get_db
	@result = db.execute 'select * from Users order by id desc' 
	db.close
	erb :'/secure/place'
end

post '/login/attempt' do
	session[:identity] = params['username']
	session[:password] = params['password']
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
	db  = get_db
	@select_from_barbers = db.execute 'select Name from  Barbers'
	erb :visit
end

post '/visit' do
	db  = get_db
	@select_from_barbers = db.execute 'select Name from  Barbers'
		@client = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = nil

	hash = {	:username => 'Введите имя',
				:phone => 'Введите номер телефона',
				:datetime => 'Введите дату и время',
	}

	@error = hash.select {|key,_| params[key]==""}.values.join(", ")
	
	if @error == ''
		db = get_db
		db.execute 'insert into
		Users
		(
			Name, 
			Phone,
			DateStamp,
			Barber,
			Color	
		)
		values (?,?,?,?,?)', [@client, @phone, @datetime, @barber, @color] 
				
		erb "Уважаемый #{@client}, #{@barber} будет ждать Вас #{@datetime}"

	else
		return erb :visit
	end
end	

	

	end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@client = params[:username]
	@email = params[:email]
	@mail = params[:mail]
	
        Pony.mail(:to => '3374555@mail.ru', :from => "#{@email}", :subject => "Сообщение от #{@client}", :body => "#{@mail}",   :via_options => {
			:address              => 'smtp.gmail.com',
			:port                 => '587',
			:enable_starttls_auto => true,
			:user_name            => 'eo0065110@gmail.com',
			:password             => 'eo0065110_google',
			:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
			:domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
		  })
	@title = "Успешно!"
	@message = "Ваше сообщение отправлено и будет обработано в ближайшее время!"
	erb :message	  

end 


  