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
    it "the error is input_missing if data is missing" do
      params = {
        "first_name"=>"", 
        "last_name"=>"LastName", 
        "email"=>"name@yahoo.com", 
        "password"=>"myPassword123$"
      }
      expect(validate_signup_input(params)).to eq("input_missing")
    end
  end
end