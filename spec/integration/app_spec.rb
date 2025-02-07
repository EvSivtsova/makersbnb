require "spec_helper"
require "rack/test"
require_relative "../../app"

def reset_makers_bnb_table
  seed_sql = File.read("spec/seeds/makers_bnb_seed.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "makers_bnb_test" })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do
    reset_makers_bnb_table
  end

  include Rack::Test::Methods

  let(:app) { Application.new }

  context "GET /signup" do
    it "returns 200 OK" do
      response = get("/signup")
      expect(response.status).to eq(200)
      expect(response.body).to include("</form>")
      expect(response.body).to include("<html>")
      expect(response.body).to include("Create Account")
      expect(response.body).to include('<input type="text" name="first_name"')
      expect(response.body).to include('<input type="text" name="last_name"')
      expect(response.body).to include('<input type="email" name="email"')
      expect(response.body).to include('<input type="password" name="password"')
      expect(response.body).to include('<input type="submit" class="submit_button" value="Sign up"/>')
    end
  end

  context "POST /signup" do
    it "create a new user and redirects to /signup/success" do
      response = post("/signup", params = { 
        first_name: "Paris", 
        last_name: "Monson", 
        email: "parismonson@yahoo.com", 
        password: "hash_password" })

      expect(last_response).to be_redirect

      user_repo = UserRepository.new.all
      expect(user_repo).to include(
        have_attributes(first_name: "Paris", last_name: "Monson", email: "parismonson@yahoo.com")
      )
    end
    it "redirects to signup view if datavalidation is unsuccessful" do
      response = post("/signup", params = { 
        first_name: "P12aris", 
        last_name: "Mon 1s on", 
        email: "parismonsonyahoo.com", 
        password: "hash_password" 
      })
      expect(last_request.url).to include("signup")
    end
    it "redirects to signup view if data is missing" do
      response = post("/signup", params = { 
        first_name: "FirstName", 
        last_name: "LastName", 
        email: "test2@example.com", 
        password: "hash_password" 
      })
      expect(last_request.url).to include("signup")
    end
  end

  context "GET /login" do
    it "returns 200 OK" do
      response = get("/login")
      expect(response.status).to eq(200)
      expect(response.body).to include("</form>")
      expect(response.body).to include("<html>")
      expect(response.body).to include("<h2>Login</h2>")
      expect(response.body).to include('<input type="email" name="email"/><br>')
      expect(response.body).to include('<input type="password" name="password"/><br>')
      expect(response.body).to include('<input type="submit" class="submit_button" value="Login"/>')
    end
  end

  context "POST /login" do
    it "redirects to / if email and password have been validated" do
      response = post("/login", params = { email: "test2@example.com", password: "password2" })
      expect(response).to be_redirect
    end

    it "shows a wrong email or password message" do
      response = post("/login", params = { email: "test2@example.com", password: "spassword2" })
      expect(response.status).to eq 200
      expect(last_request.url).to include("login")
      expect(response.body).to include("The password or email you entered is incorrect!")
      expect(response.body).to include("/login")
      expect(response.body).to include("/signup")
    end
  end

  context "GET /" do
    context "user not logged in" do
      it "shows a list of properties" do
        response = get("/")
        expect(response.status).to eq 200
        expect(response.body).to include '<h4>To book a space just sign up or login:</h4>'
        expect(response.body).to include "Sign up"
        expect(response.body).to include "Login"
        expect(response.body).to include '<div class="spaces_list">'
        expect(response.body).to include '<h2>Welcome!</h2>'
        expect(response.body).to include '<a href="/signup"'
        expect(response.body).to include '<a href="/login"'
      end
    end
    context "user logged in" do
      it "shows a list of properties to be rented, log out button and calendars" do
        post("/login", params = { email: "test2@example.com", password: "password2" })
        response = get("/")
        expect(response.status).to eq 200
        expect(response.body).to include '<h3>Book a space</h3>'
        expect(response.body).to include '<a href="/logout"'
        expect(response.body).to include "Log out"
        expect(response.body).to include '<div class="spaces_list">'
        expect(response.body).to include '<h2>Welcome John Parker!</h2>'
        expect(response.body).to include '<a href="/logout"'
        expect(response.body).to include '<a href="/space/new"'
        expect(response.body).to include 'a modern house in the mountains'
        expect(response.body).not_to include 'a modern house on the beach`'
      end
    end
  end

  context "GET /:space_id" do
    it "shows an individual space page" do
      space_id = SpaceRepository.new.all[0].space_id
      response = get space_id.to_s
      expect(response.status).to eq 200
      expect(response.body).to include "<h1>MakersBNB</h1>"
      expect(response.body).to include '<a href="/" class="index_button">Go back to homepage</a>'
      expect(response.body).to include '<p class="user">The host of this space is: John'
    end

    it "shows the booking dates when user visit somebody else property" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      space_repo = SpaceRepository.new
      space_id = space_repo.all[1].space_id
      response = get space_id.to_s
      expect(response.status).to eq 200
      expect(space_repo).to be_instance_of(SpaceRepository)
      expect(response.body).to include "<h1>MakersBNB</h1>"
      expect(response.body).to include '<a href="/"'
      expect(response.body).to include '<p class="user">The host of this space is: Anna'
      expect(response.body).to include "<label>From:</label>"
      expect(response.body).to include 'input type="date"'
      expect(response.body).to include 'name="available_from"'
      expect(response.body).to include "<label>To:</label>"
      expect(response.body).to include 'input type="date"'
      expect(response.body).to include 'name="available_to"'
      expect(response.body).to include 'input type="submit"'
    end
  end

  context "GET /signup/success" do
    it "shows a signup success message" do
      response = get("/signup/success")
      expect(response.status).to eq 200
      expect(response.body).to include("You have successfully created an account!")
      expect(response.body).to include("<html>")
      expect(response.body).to include("<a href='/login'>")
      expect(response.body).to include("<a href='/'>")
    end
  end

  context "POST /request/?" do
    context 'property is available for rent' do
      it "checks the dates and redirects to /request/success" do
        user_repo = UserRepository.new
        id = user_repo.all.first.user_id
        session = { user_id: id }
        space_repo = SpaceRepository.new
        space = space_repo.all[1]
        get(space.space_id.to_s, {}, "rack.session" => session)
        response = post('request/?', 
          params = {
            host_id: space.host_id,
            guest_id: session[:user_id],
            space_id: space.space_id,
            available_from: "18/10/2022", 
            available_to: "22/10/2022",
            confirmed: "false"
          },
            "rack.session" => session
        )
        expect(response.status).to eq 302
        expect(user_repo).to be_instance_of(UserRepository)
        expect(space_repo).to be_instance_of(SpaceRepository)
        expect(last_response).to be_redirect
        confirmation = get("/request/success")
        expect(confirmation.status).to eq 200
        expect(confirmation.body).to include("You have successfully sent a request to stay at")
        expect(confirmation.body).to include("<html>")
        expect(confirmation.body).to include("<body>")
        expect(confirmation.body).to include('<a href="/"')
        expect(confirmation.body).to include('<a href="/requests"')
      end
    end
    context 'property is not available for rent' do
      it "checks the dates and redirects to /request/failure" do
        user_repo = UserRepository.new
        id = user_repo.all.first.user_id
        session = { user_id: id }
        space_repo = SpaceRepository.new
        space = space_repo.all[1]
        get(space.space_id.to_s, {}, "rack.session" => session)
        response = post('request/?', 
          params = {
            host_id: space.host_id,
            guest_id: session[:user_id],
            space_id: space.space_id,
            available_from: "28/10/2024", 
            available_to: "22/10/2024",
            confirmed: "false"
          },
            "rack.session" => session
        )
        expect(space_repo).to be_instance_of(SpaceRepository)
        expect(user_repo).to be_instance_of(UserRepository)
        expect(response.status).to eq 200
        expect(response.body).to include("Please try again - make sure you have entered correct dates!")   
      end
    end
    context 'when looking for property and being logged out' do
      it "redirects to login" do
        space_repo = SpaceRepository.new
        space = space_repo.all[1]
        get(space.space_id.to_s)
        response = post('request/?', 
          params = {
            host_id: space.host_id,
            space_id: space.space_id,
            available_from: "28/10/2024", 
            available_to: "22/10/2024",
            confirmed: "false"
          })
        expect(space_repo).to be_instance_of(SpaceRepository)
        expect(response.status).to eq 302
        expect(last_response).to be_redirect
      end
    end
  end

  context "GET /requests" do
    it "returns 200 OK when logged in" do
      post("/login", params = { email: "ajones@example.com", password: "password3" })
      response = get("/requests")
      expect(response.status).to eq 200
      expect(response.body).to include("<html>")
      expect(response.body).to include("Requests")
    end
  end
      
  context "GET /space/new" do
    it "returns 200 OK and form for create a new space" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = get("/space/new")
      expect(response.status).to eq 200
      expect(response.body).to include('<form action="/space/new" method="POST"')
      expect(response.body).to include('<input type="text" name="title"/><br>')
      expect(response.body).to include('<input type="text" name="description"/><br>')
      expect(response.body).to include('<input type="text" name="address"/><br>')
      expect(response.body).to include('<input type="int" name="price_per_night"/><br>')
      expect(response.body).to include('<input type="date" name="available_from"/><br>')
      expect(response.body).to include('<input type="date" name="available_to"/><br>')
      expect(response.body).to include('<input type="submit" class="submit_button" value="create space"/>')
    end

    it "redirects to /login page if user not logged in" do
      response = get("/space/new")
      expect(response.status).to eq 302
      expect(response).to be_redirect  
    end
  end

  context "POST /space/new" do
    it "returns 200 OK and adds the new space to the database" do
      user_repo = UserRepository.new
      id = user_repo.all.first.user_id
      session = { user_id: id }
      get('/space/new', {}, "rack.session" => session)
      response = post('/space/new', params = { 
        title: "new title", 
        description: "new description", 
        address: "new address", 
        price_per_night: 250.00,
        available_from: "2022-07-20",
        available_to: "2022-09-20",
        host_id: session[:user_id]
      },
        "rack.session" => session)
      space_repo = SpaceRepository.new.all
      expect(space_repo).to include(
        have_attributes(title: "new title", 
        description: "new description",
        address: "new address", 
        price_per_night: "$250.00",
        available_from: "2022-07-20",
        available_to: "2022-09-20")
      ) 
      expect(response.status).to eq 200
      expect(response.body).to include('<h2>Congratulations John, you have just created a new space!</h2>')
      expect(response.body).to include('<p>Title: new title</p>')
      expect(response.body).to include('<p>Description: new description</p>')
      expect(response.body).to include('<p>Address: new address</p>')
      expect(response.body).to include('<p>Price per night: $250.00</p>')
      expect(response.body).to include('<p>Available from: 2022-07-20</p>')
      expect(response.body).to include('<p>Available to: 2022-09-20</p>')
      expect(response.body).to include('<a href="/space/new" class="button">Create a new space</a><br>')
    end

    it "renders new_space page with error message if information is missing" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = post('/space/new', params = { 
        title: "", 
        description: "test description", 
        address: "new address", 
        price_per_night: 250.00,
        available_from: "2022-07-20",
        available_to: "2022-09-20" }
      )
      repo = SpaceRepository.new
      expect { repo.create(new_space) }
      expect(response.status).to eq 200
      expect(response.body).to include('Some information is missing, please try again')
      expect(response.body).to include('<form action="/space/new"')
    end

    it "renders new_space page with error message if title contain symbols" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = post('/space/new', params = { 
        title: "net=w title &&", 
        description: "test description", 
        address: "new address", 
        price_per_night: 250.00,
        available_from: "2022-07-20",
        available_to: "2022-09-20" }
      )
      repo = SpaceRepository.new
      expect { repo.create(new_space) }
      expect(response.status).to eq 200
      expect(response.body).to include('contain letters, numbers and standard punctuation only')
      expect(response.body).to include('<form action="/space/new"')
    end

    it "renders new_space page with error message if description contain symbols" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = post('/space/new', params = { 
        title: "newtitle", 
        description: "test description £^5", 
        address: "new address", 
        price_per_night: 250.00,
        available_from: "2022-07-20",
        available_to: "2022-09-20" }
      )
      repo = SpaceRepository.new
      expect { repo.create(new_space) }
      expect(response.status).to eq 200
      expect(response.body).to include('contain letters, numbers and standard punctuation only')
      expect(response.body).to include('<form action="/space/new"')
    end

    it "renders new_space page with error message if description contain symbols" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = post('/space/new', params = { 
        title: "newtitle", 
        description: "test description", 
        address: "new address<>", 
        price_per_night: 250.00,
        available_from: "2022-07-20",
        available_to: "2022-09-20" }
      )
      repo = SpaceRepository.new
      expect { repo.create(new_space) }
      expect(response.status).to eq 200
      expect(response.body).to include('contain letters, numbers and standard punctuation only')
      expect(response.body).to include('<form action="/space/new"')
    end

    it "renders new_space page with error message if price per night is not digits" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = post('/space/new', params = { 
        title: "test title", 
        description: "test description", 
        address: "new address", 
        price_per_night: "OOO.00",
        available_from: "2022-07-20",
        available_to: "2022-09-20" }
      )
      repo = SpaceRepository.new
      expect { repo.create(new_space) }
      expect(response.status).to eq 200
      expect(response.body).to include('Price per night must be numbers only')
      expect(response.body).to include('<form action="/space/new"')
    end
  end

  context "GET /logout" do
    it "logs out the user and deletes session's details" do
      login = post('/login', params = { email: "test2@example.com", password: "password2" })
      response = get "/logout"
      expect(response.status).to eq 302
      expect(last_response).to be_redirect
    end
  end
end
