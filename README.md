MakersBNB
=================

<div align="left">
  <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/EvSivtsova/makersbnb">
</div>
<div>
  <img src="https://img.shields.io/badge/ruby-%23CC342D.svg?style=for-the-badge&logo=ruby&logoColor=white"/>&nbsp
  <img src="https://img.shields.io/badge/Sinatra-black?style=for-the-badge&logo=Sinatra&logoColor=white" alt="Sinatra"/>
  <img src="https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white"/> 
  <img src="https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white"/>
  <img src="https://img.shields.io/badge/css3-%231572B6.svg?style=for-the-badge&logo=css3&logoColor=white"/>
  <img src="https://img.shields.io/badge/RSpec-blue?style=for-the-badge&logo=Rspec&logoColor=white" alt="Rspec"/>
</div><br>

This is a team challenge from the Makers Academy week 5. We were asked to create a web app that connects property owners and potential renters, similar to AirBnb.

https://user-images.githubusercontent.com/105357551/197536980-aee98dba-c889-4d2d-8b09-c5fcff08c3d6.mp4

## Meet the team

* [Ev](https://github.com/EvSivtsova)<br>
* [Joe](https://github.com/Joseph-ER)<br>
* [Karolina](https://github.com/karolina-codes)
* [Paris](https://github.com/ParisMonson)<br>

Following the completion of the team project, I refactored the code and added tests to increase test coverage. The original project can be found [here](https://github.com/ParisMonson/makersbnb).

## TechBit

Technologies used:

* Ruby(3.0.0)
* RVM(1.29.12)
* Sinatra(2.2)
* Rack-test (2.0)
* PG(1.4)
* Webrick(1.7)

Testing:
* Rspec(3.11)
* Simplecov(Test Coverage)
* Rubocop(1.20)

Clone the repository and run bundle install to install the dependencies within the folder:

```
git clone https://github.com/EvSivtsova/makersbnb.git
cd makersbnb
bundle install
```

To run the app in the browser, create database and seed it:

```
createdb makers_bnb
psql -h 127.0.0.1 makers_bnb < spec/seeds/makers_bnb.sql
psql -h 127.0.0.1 makers_bnb < spec/seeds/makers_bnb_seed.sql
rackup
```

Go to `http://localhost:9292` to play with the app.

To confirm a reservation request, login as John Smith using the following email `test2@example.com` and password `password2`.

To run the tests:

```
createdb makers_bnb_test
psql -h 127.0.0.1 makers_bnb_test < spec/seeds/makers_bnb.sql
rspec
rubocop
```
<img src='https://github.com/EvSivtsova/makersbnb/blob/main/outputs/app_integration_test_coverage.png' width=400px>

## Planning and execution

We had less than one week to deliver the project. We used that time in the following way:
* Monday pm (0.7 day)<br>
  Sprint planning: developing user stories and designing wireframes, identifying MVP and additional features, ticket writing
* Tuesday and Wednesday am (1.5 day)<br>
  Programming to deliver MVP
* Wednesday pm and Thursday (1.5 day)<br>
  Sprint review and adding additional features
* Friday am (0.5 day)<br>
  Clean up, CSS and planning presentation
* Friday pm (0.5 day)<br>
  Presentation and sprint retrospective

Every day we had daily stand-ups to discuss our progress and ask for help as required.
 
The key challenges we faced were related to our decision to use universally unique identifiers. UUIDs are generated using random numbers every time we run tests, as such foreign keys are not known in advance and are regularly changing.
* how to design seeds for One-to-Many and Many-to-Many object relationships?
* how to test UUIDs?

We also learned how to use sessions and test them using `rack.session`.

## Code Design

When working on this chalenge, we designed **three schemas** with PostgreSQL:
1. Users schema (can be both renters and hosts).
2. Spaces schema that stores information on listed spaces. This schema references the users table to identify hosts. 
3. Reservations schema that stores reservations details:
   * space rented out (references the spaces schema),
   * renter and host identities (references the users schema),
   * start and end date of the booking, number of nights and confirmation status.
   
These schemas gave us enough flexibility to develop features in line with our user stories while minimizing the duplication of the data.

It's important to highlight that we used uuids in all three schemas and encrypted and salted users' passwords at the database level.

While creating the database and the seeds, we've test-driven models that are responsible for CRUD operations, which operate on their respective schemas:

1. User and User Repository Classes
2. Space and Space Repository Classes
3. Reservation and Reservation Repository Classes

Afterwards we've test-driven the Application class, which functions as a controller, and the views, thus connecting the frontend and the backend. 

The result is a simple app that allows the users to:
* create accounts 
* list spaces
* send reservation requests with the use of calendar
* see the list of reservations we've made and received
* approve reservation requests

## MiniBug :bug:

CCS is not rendering on some pages. The affected views are: `individual_space` in case of an input error, `new_space_success`, `signup_success` and `request_success`. In a nutshell, no success with CSS on success pages.

If you know why, [let me know](mailto:evcodes12@gmail.com). Thank you!! :sparkles:
