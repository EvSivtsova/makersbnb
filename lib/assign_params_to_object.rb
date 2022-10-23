require_relative "user"
require_relative "space"
require_relative "reservation"

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
  new_space.host_id = params[:host_id]
  return new_space
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
