require 'assign_params_to_object'
require "rack/test"

describe "object creating methods" do
  context "when creating a user" do
    it "assigns values and creates a user" do
      params = {
        first_name: "FirstName", 
        last_name: "LastName", 
        email: "email@yahoo.com", 
        password: "hash_password"
      }
      result = assign_params_to_user(params)
      expect(result.first_name).to eq "FirstName"
      expect(result.last_name).to eq "LastName"
      expect(result.email).to eq "email@yahoo.com"
      expect(result.password).to eq "hash_password"
    end
  end

  context "when creating a space" do
    it "assigns values and creates a user" do
      params = {
        title: "new title", 
        description: "new description", 
        address: "new address", 
        price_per_night: "250.00", 
        available_from: "2022-07-20", 
        available_to: "2022-09-20"
      }
      result = assign_params_to_space(params, "aec3f85a-77a0-49d6-ad15-b5a82bd228cd")
      expect(result.title).to eq "new title"
      expect(result.description).to eq "new description"
      expect(result.address).to eq "new address"
      expect(result.price_per_night).to eq "250.00"
      expect(result.available_from).to eq "2022-07-20"
      expect(result.available_to).to eq "2022-09-20"
    end
  end
end