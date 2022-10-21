def validate_input(params)
  @error = nil
  if missing_data?(params)
    @error = "missing information error"
  elsif params[:price_per_night].match?(/[^\d.]/)
    @error = "price format error"
  elsif params[:title].match?(/[^\w\s?!.,']/i)
    @error = "invalid title"
  elsif params[:description].match?(/[^\w\s?!.,']/i)
    @error = "invalid description" 
  elsif params[:address].match?(/[^\w\s.,']/i)
    @error = "invalid address"
  end
  return @error
end

def signup_input_validation(params)
  users_repo = UserRepository.new
  if missing_data?(params)
    @error = "input_missing"
  elsif (params[:first_name].match?(/[^a-z\s-]{2,30}/i)|| params[:last_name].match?(/[^a-z\s-]{2,30}/i))
    @error = "invalid_name"
  elsif !users_repo.find_user(params[:email]).nil?
    @error = "existing_email"
  end
  return @error
end

def missing_data?(params)
  errors = []
  params.each do |param|
    return if param[0] == "description"
    errors < param if param[1].empty?
  end
  return !errors.empty?
end