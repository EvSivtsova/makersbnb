require 'validate_input'

describe "validate input methods" do
  context "when testing for missing data?" do
    it 'missing_data? returns true if any data in params array is missing' do
      params = {
        "first_name"=>"FirstName", 
        "last_name"=>"", 
        "email"=>"@yahoo.com", 
        "password"=>"hash_password"
      }
      expect(missing_data?(params)).to be(true)
    end

    it 'missing_data? returns true if any data in params array is missing' do
      params = {
        "first_name"=>"FirstName", 
        "last_name"=>"LastName", 
        "email"=>"fvd@yahoo.com", 
        "password"=>"hash_password"
      }
      expect(missing_data?(params)).to be(false)
    end
  end

  context "when testing for user email" do
    it "returns nil if the email exists in the database" do
      result = email_unique?("test2@example.com")
      expect(result).to eq(nil)
    end

    it "returns true if the email does not exist in the database" do
      result = email_unique?("test25@example.com")
      expect(result).to eq(true)
    end
  end

  context "when validating signup form" do
    xit "the error is nil if data is correct" do
      params = {
        "first_name" => "FirstName", 
        "last_name"=>"LastName".to_s, 
        "email"=>"name@yahoo.com".to_s, 
        "password"=>"myPassword123$".to_s
      }
      expect(validate_signup_input(params)).to eq(nil)
    end

    it "the error is input_missing if data is missing" do
      params = {
        "first_name"=>"", 
        "last_name"=>"LastName", 
        "email"=>"name@yahoo.com", 
        "password"=>"myPassword123$"
      }
      expect(validate_signup_input(params)).to eq("input_missing")
    end

    xit "the error is invalid_name if forbidden characters are used" do
      params = {
        "first_name"=>"FirstName", 
        "last_name"=>"123LastName", 
        "email"=>"name@yahoo.com", 
        "password"=>"myPassword123$"
      }
      expect(validate_signup_input(params)).to eq("invalid_name")
    end

    xit "the error is existing_email if email exists in the database" do
      params = {
        "first_name"=>"FirstName", 
        "last_name"=>"LastName", 
        "email"=>"test2@example.com", 
        "password"=>"myPassword123$"
      }
      expect(validate_signup_input(params)).to eq(nil)
    end
  end

  context "when validating new space form" do
    xit "the error is nil if data is correct" do
      params = {
        "title"=>"new title",
        "description"=>"new description",
        "address"=>"new address",
        "price_per_night"=>"250.0",
        "available_from"=>"2022-07-20",
        "available_to"=>"2022-09-20"
      }
      expect(validate_signup_input(params)).to eq(nil)
    end

    it "the error is 'missing information error' if data is correct" do
      params = {
        "title"=>"",
        "description"=>"new description",
        "address"=>"new address",
        "price_per_night"=>"250.0",
        "available_from"=>"2022-07-20",
        "available_to"=>"2022-09-20"
      }
      expect(validate_input_space(params)).to eq('missing information error')
    end
  end
end