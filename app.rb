require "sinatra/base"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/user_repository"
require_relative "lib/space_repository"
require_relative "lib/reservation_repository"
require_relative "./lib/validate_dates"
require_relative "./lib/validate_input"

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    enable :sessions
  end

  get "/" do
    @spaces = SpaceRepository.new.all
    @user_repo = UserRepository.new
    @logged_in_user = UserRepository.new.find_by_id(session[:user_id]) if session[:user_id]
    erb :index
  end

  get "/signup" do
    return erb(:signup)
  end

  post "/signup" do
    validate_signup_input(params)
    return erb(:signup) unless @error.nil?
    users_repo = UserRepository.new
    new_user = assign_params_to_user(params)
    users_repo.create_user(new_user)
    @user = users_repo.find_user(params[:email])
    session[:user_id] = @user.user_id
    redirect "/signup/success"
  end

  get "/signup/success" do
    return erb(:signup_success)
  end

  get "/login" do
    return erb(:login)
  end

  post "/login" do
    users_repo = UserRepository.new
    if users_repo.valid_login?(params[:email], params[:password])
      @user = users_repo.find_user(params[:email])
      session[:user_id] = @user.user_id
      redirect "/"
    end
    @error = true
    erb(:login)
  end

  get "/logout" do
    session.delete(:user_id)
    redirect "/"
  end

  post "/request/?" do
    redirect "/login" if session[:user_id].nil?
    if valid_availability?(params[:available_from], params[:available_to]) == false
      @error = "Please try again - make sure you have entered dates!"
      space_id = params[:space_id]
      @space = SpaceRepository.new.find_by_space_id(space_id)
      @host_name = UserRepository.new.find_by_id(@space.host_id).first_name
      return erb :individual_space
    end
    reservation_repo = ReservationRepository.new
    new_reservation = assign_params_to_reservation(params)
    reservation_repo.create(new_reservation)
    redirect "/request/success"
  end

  get "/request/success" do
    redirect "/login" if session[:user_id].nil?
    erb :request_success
  end
  
  get "/requests" do
    redirect "/login" if session[:user_id].nil?
    @reservation_repo = ReservationRepository.new
    @space_repo = SpaceRepository.new
    @user_repo = UserRepository.new
    @id = session[:user_id]
    return erb(:requests)
  end

  get "/newspace" do
    redirect "/login" if session[:user_id].nil?
    return erb(:new_space)
  end

  post "/newspace" do
    redirect "/login" if session[:user_id].nil?
    validate_input_space(params)
    return erb(:new_space) unless @error.nil?
    spaces_repo = SpaceRepository.new
    new_space = assign_params_to_space(params)
    spaces_repo.create(new_space)
    @space = SpaceRepository.new.find_by_host_id(session[:user_id])[-1]
    @host = UserRepository.new.find_by_id(session[:user_id])
    erb(:new_space_success)
  end

  get "/:space_id" do
    space_id = params[:space_id]
    @space = SpaceRepository.new.find_by_space_id(space_id)
    @host_name = UserRepository.new.find_by_id(@space.host_id).first_name
    erb :individual_space
  end
  
  post "/requests/:reservation_id" do
    redirect "/login" if session[:user_id].nil?
    repo = ReservationRepository.new
    repo.confirm_reservation(params[:reservation_id])
    redirect "/requests"
  end

  private
  
  def valid_availability?(start_date_string, end_date_string)
    return false if start_date_string.empty? || end_date_string.empty?
    space_repo = SpaceRepository.new
    space = space_repo.find_by_space_id(params[:space_id])
    check_dates_within_availability_range?(start_date_string, end_date_string, 
        space.available_from, space.available_to)
  end

  def assign_params_to_reservation(params)
    reservation = Reservation.new
    reservation.host_id = params[:host_id]
    reservation.guest_id = params[:guest_id]
    reservation.space_id = params[:space_id]
    reservation.start_date = Date.parse(params[:available_from])
    reservation.end_date = Date.parse(params[:available_to])
    reservation.number_night = (reservation.end_date - reservation.start_date).to_i
    reservation.confirmed = 'false'
    return reservation
  end

  def assign_params_to_user(params)
    new_user = User.new
    new_user.first_name = params[:first_name]
    new_user.last_name = params[:last_name]
    new_user.email = params[:email]
    new_user.password = params[:password]
    return new_user
  end

  def assign_params_to_space(params)
    new_space = Space.new
    new_space.title = params[:title]
    new_space.description = params[:description]
    new_space.address = params[:address]
    new_space.price_per_night = params[:price_per_night]
    new_space.available_from = params[:available_from]
    new_space.available_to = params[:available_to]
    new_space.host_id = session[:user_id]
    return new_space
  end
end
