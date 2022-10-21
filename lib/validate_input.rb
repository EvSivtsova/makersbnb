require_relative 'user_repository'

def signup_input_validation(params)
  users_repo = UserRepository.new
  if missing_data?(params)
    @error = "input_missing"
  elsif (params[:first_name].match?(/[^a-z\s-]{2,30}/i)|| params[:last_name].match?(/[^a-z\s-]{2,30}/i))
    @error = "invalid_name"
  elsif email_unique?(params[:email]) == nil
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
