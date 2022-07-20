require "sinatra/base"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/user_repository"
require_relative "lib/space_repository"
require_relative "lib/reservation_repository"

DatabaseConnection.connect

class Application < Sinatra::Base
  # This allows the app code to refresh
  # without having to restart the server.
  configure :development do
    register Sinatra::Reloader
    enable :sessions
  end

  get "/signup" do
    return erb(:signup)
  end

  post "/signup" do
    repo_users = UserRepository.new
    new_user = User.new
    new_user.first_name = params[:first_name]
    new_user.last_name = params[:last_name]
    new_user.email = params[:email]
    new_user.password = params[:password]
    repo_users.create_user(new_user)
    @user = repo_users.find_by_email(params[:email])
    ### to look into user_id and sessions
    # session[:user_id] = @user.user_id
    return erb(:spaces) ###
    # to add a conditional - if the input data is correct
  end

  get "/login" do
    return erb(:login)
  end

  post "/login" do
    repo_users = UserRepository.new
    if repo_users.valid_login?(params[:email], params[:password])
      @user = repo_users.find_by_email(params[:email])
      ### to look into user_id and sessions
      session[:user_id] = @user.user_id
      return erb(:spaces) ###
      # to add a conditional - if the input data is correct
    end
  end

  get "/" do
    @spaces = SpaceRepository.new.all
    @user_repo = UserRepository.new
    @logged_in_user = UserRepository.new.find_by_id(session[:user_id]) if session[:user_id]

    erb :index
  end

  get "/:host_name/:title" do
    @host_name = params[:host_name].split("_").join(" ")
    @title = params[:title].split("_").join(" ")

    @space = SpaceRepository.new.find_by_title(@title)[0]

    erb :individual_space
  end
end
