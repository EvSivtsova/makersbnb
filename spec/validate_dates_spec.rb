require "validate_dates"

describe "check the dates are within the availability range" do
  context "when comparing date strings in the same format" do
    it "returns true when the start and end dates are within the range" do
      start_date = "2022/03/01"
      available_from = "2022/02/01"
      end_date = "2022/04/01"
      available_to = "2022/05/01"
      result = check_dates_within_availability_range?(start_date, end_date, available_from, available_to)
      expect(result).to be(true)
    end

    it "returns false when the start and end dates are not within the range" do
      start_date = "2022/01/01"
      available_from = "2022/02/01"
      end_date = "2022/04/01"
      available_to = "2022/03/01"
      result = check_dates_within_availability_range?(start_date, end_date, available_from, available_to)
      expect(result).to be(false)
    end
  end
end
