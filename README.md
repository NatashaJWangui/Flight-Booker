# NJW Flight Booker ✈️

This is part of the Advanced Forms Project in The Odin Project's Ruby on Rails Curriculum. Find it at https://www.theodinproject.com

A comprehensive one-way flight booking application that demonstrates advanced Rails forms, nested attributes, complex queries, and multi-step user workflows. Built with Ruby on Rails and PostgreSQL to showcase enterprise-level form handling and user experience design.

## Features

- **Advanced Search**: Multi-parameter flight search with airports, dates, and passengers
- **Dynamic Flight Results**: Real-time filtering and display of available flights
- **Complex Form Handling**: Nested passenger information forms with validation
- **Multi-step Workflow**: Search → Select → Book → Confirm process
- **Professional UI**: Airline-quality interface with responsive design
- **PostgreSQL Database**: Production-ready database with complex relationships
- **Smart Validation**: Client and server-side validation with error handling
- **Booking Management**: Complete booking lifecycle with confirmation

## Technologies Used

- **Ruby**: 3.4.4
- **Rails**: 8.0.2
- **PostgreSQL**: Production-grade database
- **Advanced Forms**: `accepts_nested_attributes_for`, `fields_for`
- **Complex Queries**: Multi-table joins and filtering
- **Date Handling**: Rails DateHelper and datetime manipulation
- **Responsive CSS**: Modern UI with mobile support

## Application Architecture

### Models & Relationships

```ruby
# Airport Model
- airport_code: string (3 chars, unique)
- name: string
- has_many :departing_flights, :arriving_flights

# Flight Model  
- departure_airport_id: references
- arrival_airport_id: references
- start_datetime: datetime
- duration: integer (minutes)
- belongs_to :departure_airport, :arrival_airport
- has_many :bookings

# Booking Model
- flight_id: references
- total_passengers: integer
- belongs_to :flight
- has_many :passengers
- accepts_nested_attributes_for :passengers

# Passenger Model
- booking_id: references
- name: string
- email: string
- belongs_to :booking
```

### Database Schema

```sql
-- Airports Table
CREATE TABLE airports (
  id SERIAL PRIMARY KEY,
  airport_code VARCHAR(3) UNIQUE NOT NULL,
  name VARCHAR NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Flights Table
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  departure_airport_id INTEGER REFERENCES airports(id),
  arrival_airport_id INTEGER REFERENCES airports(id),
  start_datetime TIMESTAMP NOT NULL,
  duration INTEGER NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Bookings Table
CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  flight_id INTEGER REFERENCES flights(id),
  total_passengers INTEGER NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Passengers Table
CREATE TABLE passengers (
  id SERIAL PRIMARY KEY,
  booking_id INTEGER REFERENCES bookings(id),
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Installation

### Prerequisites
- Ruby 3.0 or higher
- Rails 7.0 or higher
- PostgreSQL 12 or higher
- Git

### Setup
1. **Clone the repository**
   ```bash
   git clone https://github.com/NatashaJWangui/Flight-Booker.git
   cd flight-booker
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database setup**
   ```bash
   # Start PostgreSQL service
   # macOS: brew services start postgresql
   # Ubuntu: sudo service postgresql start
   
   # Create and setup database
   rails db:create
   rails db:migrate
   rails db:seed  # Creates airports and flights
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   Open your browser and navigate to `http://localhost:3000`

## User Journey

### Step 1: Flight Search
- **Departure Airport**: Select from available airports
- **Arrival Airport**: Choose destination airport  
- **Date**: Pick from dates with available flights
- **Passengers**: Select 1-4 passengers
- **Search**: Find matching flights

### Step 2: Flight Selection
- **View Results**: See available flights with details
- **Flight Cards**: Route, times, duration, flight number
- **Radio Selection**: Choose preferred flight
- **Book Flight**: Proceed to passenger information

### Step 3: Passenger Information
- **Flight Summary**: Review selected flight details
- **Passenger Forms**: Dynamic forms for each passenger
- **Validation**: Name and email required for each passenger
- **Cost Calculation**: Automatic pricing based on flight and passengers
- **Complete Booking**: Submit all passenger information

### Step 4: Booking Confirmation
- **Confirmation Number**: Unique booking reference
- **Flight Details**: Complete itinerary information
- **Passenger List**: All traveler information
- **Payment Summary**: Detailed cost breakdown
- **Next Steps**: Travel preparation instructions

## Key Features Deep Dive

### Advanced Form Handling

#### Multi-Parameter Search
```ruby
# FlightsController#index
def index
  @airports = Airport.all.order(:airport_code)
  @flight_dates = Flight.distinct.pluck(:start_datetime).map(&:to_date).uniq.sort
  
  if params[:departure_airport_id].present?
    @flights = Flight.includes(:departure_airport, :arrival_airport)
                    .departing_from(params[:departure_airport_id])
                    .arriving_at(params[:arrival_airport_id])
                    .on_date(params[:date])
                    .order(:start_datetime)
  end
end
```

#### Nested Attributes Implementation
```ruby
# Booking Model
class Booking < ApplicationRecord
  belongs_to :flight
  has_many :passengers, dependent: :destroy
  
  accepts_nested_attributes_for :passengers
  
  validates :total_passengers, presence: true, numericality: { in: 1..4 }
  validates :passengers, length: { minimum: 1 }
end

# BookingsController#new
def new
  @flight = Flight.find(params[:flight_id])
  @num_passengers = params[:num_passengers].to_i
  
  @booking = Booking.new(flight: @flight, total_passengers: @num_passengers)
  
  # Create blank passenger objects for the form
  @num_passengers.times { @booking.passengers.build }
end
```

#### Dynamic Form Generation
```erb
<!-- Passenger Information Forms -->
<%= form.fields_for :passengers do |passenger_form| %>
  <div class="passenger-card">
    <h3>Passenger <%= passenger_form.index + 1 %></h3>
    
    <div class="form-row">
      <div class="form-group">
        <%= passenger_form.label :name, "Full Name" %>
        <%= passenger_form.text_field :name, class: "form-control" %>
      </div>
      
      <div class="form-group">
        <%= passenger_form.label :email, "Email Address" %>
        <%= passenger_form.email_field :email, class: "form-control" %>
      </div>
    </div>
  </div>
<% end %>
```

### Complex Database Queries

#### Flight Search Scopes
```ruby
# Flight Model Scopes
scope :departing_from, ->(airport_id) { where(departure_airport_id: airport_id) }
scope :arriving_at, ->(airport_id) { where(arrival_airport_id: airport_id) }
scope :on_date, ->(date) { where('DATE(start_datetime) = ?', date) }

# Usage
@flights = Flight.includes(:departure_airport, :arrival_airport)
                .departing_from(params[:departure_airport_id])
                .arriving_at(params[:arrival_airport_id])
                .on_date(params[:date])
                .order(:start_datetime)
```

#### Association Queries
```ruby
# Airport associations with custom foreign keys
has_many :departing_flights, class_name: 'Flight', foreign_key: 'departure_airport_id'
has_many :arriving_flights, class_name: 'Flight', foreign_key: 'arrival_airport_id'

# Flight associations with custom class names
belongs_to :departure_airport, class_name: 'Airport'
belongs_to :arrival_airport, class_name: 'Airport'
```

### Data Seeding Strategy

#### Realistic Flight Data
```ruby
# Smart route-based flight scheduling
route_durations = {
  'SFO-LAX' => 90, 'LAX-SFO' => 90,
  'SFO-JFK' => 330, 'JFK-SFO' => 360,
  'LAX-JFK' => 310, 'JFK-LAX' => 340
}

# Popular routes have more flights
num_flights = case route_key
when 'SFO-LAX', 'LAX-SFO', 'SFO-JFK', 'JFK-SFO'
  rand < 0.8 ? departure_times.sample(rand(2..4)) : []
else
  rand < 0.3 ? departure_times.sample(rand(1..2)) : []
end
```

## Routes

| HTTP Method | Path | Controller#Action | Purpose |
|-------------|------|------------------|---------|
| GET | / | flights#index | Flight search and results |
| GET | /flights | flights#index | Flight search and results |
| GET | /bookings/new | bookings#new | Passenger information form |
| POST | /bookings | bookings#create | Create new booking |
| GET | /bookings/:id | bookings#show | Booking confirmation |

## Form Parameter Flow

### Search Parameters
```ruby
# GET /flights?departure_airport_id=1&arrival_airport_id=2&date=2024-01-15&num_passengers=2
params = {
  departure_airport_id: "1",
  arrival_airport_id: "2", 
  date: "2024-01-15",
  num_passengers: "2"
}
```

### Flight Selection Parameters  
```ruby
# GET /bookings/new?flight_id=5&num_passengers=2
params = {
  flight_id: "5",
  num_passengers: "2"
}
```

### Booking Creation Parameters
```ruby
# POST /bookings
params = {
  booking: {
    flight_id: "5",
    total_passengers: "2",
    passengers_attributes: {
      "0" => { name: "John Doe", email: "john@example.com" },
      "1" => { name: "Jane Doe", email: "jane@example.com" }
    }
  }
}
```

## Validation & Error Handling

### Model Validations
```ruby
# Airport validations
validates :airport_code, presence: true, uniqueness: true, length: { is: 3 }
validates :name, presence: true

# Flight validations  
validates :start_datetime, presence: true
validates :duration, presence: true, numericality: { greater_than: 0 }

# Booking validations
validates :total_passengers, presence: true, numericality: { in: 1..4 }
validates :passengers, length: { minimum: 1 }

# Passenger validations
validates :name, presence: true
validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
```

### Controller Error Handling
```ruby
# BookingsController
def create
  @booking = Booking.new(booking_params)
  
  if @booking.save
    redirect_to @booking, notice: 'Booking was successfully created!'
  else
    @flight = @booking.flight
    @num_passengers = @booking.total_passengers
    # Rebuild passenger objects if validation fails
    while @booking.passengers.length < @num_passengers
      @booking.passengers.build
    end
    render :new, status: :unprocessable_entity
  end
end
```

## Testing

### Manual Testing Checklist

#### Search Functionality
- [ ] Can select different airport combinations
- [ ] Date field properly restricts to available dates
- [ ] Passenger count validation (1-4 passengers)
- [ ] Search returns appropriate results
- [ ] "No results" message displays when no flights found
- [ ] Form retains values after search

#### Flight Selection
- [ ] Flight cards display all necessary information
- [ ] Radio button selection works correctly  
- [ ] Flight details (times, duration, airports) are accurate
- [ ] Can proceed to booking with valid selection
- [ ] Error handling for missing flight selection

#### Passenger Information
- [ ] Correct number of passenger forms generated
- [ ] Name validation works (required field)
- [ ] Email validation works (required, proper format)
- [ ] Form retains data on validation errors
- [ ] Cost calculation displays correctly
- [ ] Flight summary shows selected flight details

#### Booking Confirmation
- [ ] Confirmation number generates and displays
- [ ] All flight details are accurate
- [ ] All passenger information is correct
- [ ] Cost breakdown is accurate
- [ ] Print functionality works
- [ ] Navigation links work properly

### Console Testing
```ruby
# Test associations
airport = Airport.first
airport.departing_flights.count  # Flights departing from this airport
airport.arriving_flights.count   # Flights arriving at this airport

flight = Flight.first
flight.departure_airport.name    # Departure airport name
flight.arrival_airport.name     # Arrival airport name
flight.bookings.count           # Number of bookings for this flight

booking = Booking.first
booking.flight.start_datetime   # Flight departure time
booking.passengers.count        # Number of passengers
booking.total_cost             # Total booking cost

# Test scopes
Flight.departing_from(1).count          # Flights from airport ID 1
Flight.on_date(Date.current).count      # Flights today
Flight.includes(:departure_airport, :arrival_airport).first.departure_airport.name
```

## Security Considerations

### Parameter Security
- **Strong Parameters**: Whitelisted form parameters prevent mass assignment
- **Nested Attributes**: Properly configured to accept only allowed passenger fields
- **Input Validation**: Server-side validation for all user inputs
- **SQL Injection Prevention**: ActiveRecord parameterized queries

### Data Validation
- **Required Fields**: All critical information validated for presence
- **Format Validation**: Email format validation
- **Numerical Constraints**: Passenger count limited to realistic range
- **Date Validation**: Prevents booking flights in the past

## Performance Considerations

### Database Optimization
- **Indexes**: Foreign key columns automatically indexed
- **Eager Loading**: `includes()` prevents N+1 queries in flight listings
- **Scopes**: Efficient database queries for flight search
- **Query Optimization**: Minimal database calls in views

### Future Optimizations
- **Caching**: Page caching for airport lists and flight search
- **Background Jobs**: Email confirmations and notifications
- **API Integration**: Real-time flight data updates
- **Search Indexing**: Full-text search capabilities

## Deployment

### Heroku Deployment
```bash
# Prepare for production
echo "ruby '3.4.4'" >> Gemfile
bundle install

# Create Heroku app
heroku create your-flight-booker
heroku addons:create heroku-postgresql:mini

# Deploy
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed

# Set environment variables
heroku config:set RAILS_MASTER_KEY=your_master_key
```

### Production Considerations
- **Database Connection Pooling**: Configure for concurrent users
- **Asset Pipeline**: Precompile assets for production
- **Error Monitoring**: Add services like Rollbar or Sentry
- **Performance Monitoring**: Add APM tools for database query analysis

## Future Enhancements

### User Experience
- **User Accounts**: Save booking history and preferences
- **Multi-city Trips**: Support for complex itineraries
- **Seat Selection**: Visual seat maps and preferences
- **Mobile App**: Native iOS/Android applications
- **Real-time Updates**: Flight status and gate changes

### Business Features
- **Payment Integration**: Stripe or PayPal integration
- **Pricing Engine**: Dynamic pricing based on demand
- **Loyalty Program**: Frequent flyer miles and rewards
- **Corporate Accounts**: Business travel management
- **Group Bookings**: Special handling for large groups

### Technical Improvements
- **API Development**: RESTful API for third-party integrations
- **Microservices**: Split into booking, payment, and notification services
- **Real-time Data**: Integration with airline reservation systems
- **Machine Learning**: Price prediction and recommendation engine
- **Advanced Search**: Filters for price range, airlines, stops

## Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Resources

- [Rails Guides - Form Helpers](https://guides.rubyonrails.org/form_helpers.html)
- [Rails API - accepts_nested_attributes_for](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [The Odin Project](https://www.theodinproject.com/)

## License

This project is for educational purposes.

## Acknowledgments

- The Odin Project for the comprehensive advanced forms curriculum
- PostgreSQL community for the powerful database system
- Rails community for excellent form handling capabilities
- All developers contributing to complex Rails application patterns

---

**Project completed as part of The Odin Project - Ruby on Rails Course**

*Taking flight with advanced Rails forms and enterprise-level user experiences! ✈️*