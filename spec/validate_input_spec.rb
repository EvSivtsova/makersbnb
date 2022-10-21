require 'validate_input'

describe "validate input methods" do
  context "when testing for missing data?" do
    it 'missing_data? returns true if any data in params array is missing' do
      params = {"first_name"=>"FirstName", "last_name"=>"", "email"=>"@yahoo.com", "password"=>"hash_password"}
      expect(missing_data?(params)).to be(true)
    end
    it 'missing_data? returns true if any data in params array is missing' do
      params = {"first_name"=>"FirstName", "last_name"=>"LastName", "email"=>"fvd@yahoo.com", "password"=>"hash_password"}
      expect(missing_data?(params)).to be(false)
    end
  end
end