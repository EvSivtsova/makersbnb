require "sinatra/base"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/user_repository"
require_relative "lib/space_repository"
require_relative "lib/reservation_repository"
require_relative "./lib/validate_dates"
require_relative "./lib/validate_input"
require_relative "./lib/assign_params_to_object"

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    enable :sessions
  end

  get "/" do
    @spaces = SpaceRepository.new.all
    @logged_in_user = UserRepository.new.find_by_id(session[:user_id]) if session[:user_id]
    erb :index
  end

  get "/signup" do
    return erb(:signup)
  end

  post "/signup" do
    validate_signup_input(params)
    return erb(:signup) unless @error.nil?
    @users = UserRepository.new
    new_user = assign_params_to_user(params)
    @users.create_user(new_user)
    session[:user_id] = assign_session(params[:email])
    redirect "/signup/success"
  end

  get "/signup/success" do
    return erb(:signup_success)
  end

  get "/login" do
    return erb(:login)
  end

  post "/login" do
    @users = UserRepository.new
    if @users.valid_login?(params[:email], params[:password])
      session[:user_id] = assign_session(params[:email])
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
    unless valid_availability?(params[:available_from], params[:available_to])
      @error = "Please try again - make sure you have entered dates!"
      space_id = params[:space_id]
      @space = SpaceRepository.new.find_by_space_id(space_id)
      @host_name = UserRepository.new.find_by_id(@space.host_id).first_name
      return erb :individual_space
    end
    reservations = ReservationRepository.new
    new_reservation = assign_params_to_reservation(params)
    reservations.create(new_reservation)
    redirect "/request/success"
  end

  get "/request/success" do
    redirect "/login" if session[:user_id].nil?
    erb :request_success
  end
  
  get "/requests" do
    redirect "/login" if session[:user_id].nil?
    @reservations = ReservationRepository.new
    @spaces = SpaceRepository.new
    @users = UserRepository.new
    @id = session[:user_id]
    return erb(:requests)
  end

  get "/space/new" do
    redirect "/login" if session[:user_id].nil?
    return erb(:new_space)
  end

  post "/space/new" do
    redirect "/login" if session[:user_id].nil?
    validate_input_space(params)
    return erb(:new_space) unless @error.nil?
    spaces = SpaceRepository.new
    new_space = assign_params_to_space(params, session[:user_id])
    spaces.create(new_space)
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

  def assign_session(email)
    @user = @users.find_user(email)
    @user.user_id
  end
end
