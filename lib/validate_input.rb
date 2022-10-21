require_relative 'user_repository'

def validate_input_space(params)
  regex_text = /[^\w\s?!.,']/i
  regex_address = /[^\w\s.,']/i
  if missing_data?(params)
    @error = "missing information error"
  elsif params[:price_per_night].match?(/[^\d.]/)
    @error = "price format error"
  elsif params[:title].match?(regex_text)
    @error = "invalid title"
  elsif params[:description].match?(regex_text)
    @error = "invalid description" 
  elsif params[:address].match?(regex_address)
    @error = "invalid address"
  end
  return @error
end

def validate_signup_input(params)
  regex_name = /[^a-z\s-]{2,30}/i
  if missing_data?(params)
    @error = "input_missing"
  elsif (params[:first_name].match?(regex_name) || params[:last_name].match?(regex_name))
    @error = "invalid_name"
  elsif email_unique?(params[:email]).nil?
    @error = "existing_email"
  end
  return @error
end

def missing_data?(params)
  errors = []
  params.each do |key, value|
    errors << key if value.empty? && key != "description"
  end
  return !errors.empty?
end

def email_unique?(email)
  users_repo = UserRepository.new
  return true if users_repo.find_user(email).nil?
end
