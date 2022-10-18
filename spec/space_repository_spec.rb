require_relative "../lib/space_repository"

def reset_tables
  seed_sql = File.read("spec/seeds/makers_bnb_seed.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makers_bnb_test" })
  connection.exec(seed_sql)
end

describe SpaceRepository do
  before(:each) do
    reset_tables
  end

  it "returns all spaces" do
    repo = SpaceRepository.new
    spaces = repo.all
    expect(spaces.length).to eq 4
    expect(spaces.first.address).to eq "Camber S1 00J"
    expect(spaces.first.title).to eq "beach view"
    expect(spaces.first.description).to eq "a modern house on the beach"
    expect(spaces.first.price_per_night).to eq "$100.00"
    expect(spaces.first.available_from).to eq "2022-07-19"
    expect(spaces.first.available_to).to eq "2023-11-19"
    expect(spaces.last.address).to eq "London SW1 0UJ"
    expect(spaces.last.title).to eq "city getaway"
    expect(spaces.last.description).to eq "a bright private room in Central London"
    expect(spaces.last.available_from).to eq "2022-07-19"
    expect(spaces.last.available_to).to eq "2023-07-17"
  end

  it "finds a space by host_id" do
    repo = SpaceRepository.new
    host_id = repo.all.first.host_id
    space = repo.find_by_host_id(host_id)[0]
    expect(space.address).to eq "Camber S1 00J"
    expect(space.title).to eq "beach view"
    expect(space.price_per_night).to eq "$100.00"
    expect(space.description).to eq "a modern house on the beach"
    expect(space.available_from).to eq "2022-07-19"
    expect(space.available_to).to eq "2023-11-19"
  end

  it "adds a new space to the repo" do
    repo = SpaceRepository.new
    repo.create(double(:space, address: "address", title: "title", description: "description", price_per_night: "$100.00", available_from: "2022/07/19", available_to: "2022/08/01", host_id: repo.all.first.host_id))
    spaces = repo.all
    expect(spaces.length).to eq 5
    expect(spaces.last.address).to eq "address"
    expect(spaces.last.title).to eq "title"
    expect(spaces.last.price_per_night).to eq "$100.00"
    expect(spaces.last.description).to eq "description"
    expect(spaces.last.available_from).to eq "2022-07-19"
    expect(spaces.last.available_to).to eq "2022-08-01"
  end

  it "deletes a space from the repo" do
    repo = SpaceRepository.new
    repo.create(double(:space, address: "address", title: "title", description: "description", price_per_night: "$100.00", available_from: "2022/07/19", available_to: "2022/08/01", host_id: repo.all.first.host_id))
    id = repo.all[-1].space_id 
    repo.delete(id)
    spaces = repo.all
    expect(spaces.length).to eq 4
    expect(spaces.last.address).to eq "London SW1 0UJ"
    expect(spaces.last.title).to eq "city getaway"
    expect(spaces.last.description).to eq "a bright private room in Central London"
    expect(spaces.last.price_per_night).to eq "$300.00"
    expect(spaces.last.available_from).to eq "2022-07-19"
    expect(spaces.last.available_to).to eq "2023-07-17"
  end

  it "updates the description of a space" do
    repo = SpaceRepository.new
    spaces = repo.all
    space = spaces.first
    space.description = "new description"
    repo.update_description(space)
    expect(spaces.first.description).to eq "new description"
  end

  it "updates the title of a space" do
    repo = SpaceRepository.new
    spaces = repo.all
    space = spaces.first
    space.title = "new title"
    repo.update_title(space)
    expect(spaces.first.title).to eq "new title"
  end

  it "updates the availability of a space" do
    repo = SpaceRepository.new
    spaces = repo.all
    space = spaces.last
    space.available_from = "2022-08-01"
    space.available_to = "2022-08-02"
    repo.update_availability(space)
    expect(spaces.last.available_from).to eq "2022-08-01"
    expect(spaces.last.available_to).to eq "2022-08-02"
  end

  it "finds a space by title" do
    repo = SpaceRepository.new
    space = repo.find_by_title("beach view")[0]
    expect(space.description).to eq "a modern house on the beach"
    expect(space.price_per_night).to eq "$100.00"
  end

  it "finds a space by id" do
    repo = SpaceRepository.new
    id = repo.find_by_title("beach view")[0].space_id
    space = repo.find_by_space_id(id)
    expect(space.description).to eq "a modern house on the beach"
    expect(space.price_per_night).to eq "$100.00"
  end
end
