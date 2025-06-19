# NJW Flight Booker ✈️ - International Edition

This is part of the Advanced Forms Project in The Odin Project's Ruby on Rails Curriculum. Find it at https://www.theodinproject.com

A comprehensive international flight booking application featuring routes across **North America, Europe, and Africa**. Demonstrates advanced Rails forms, nested attributes, complex queries, multi-step workflows, and professional email confirmations. Built with Ruby on Rails and PostgreSQL to showcase enterprise-level form handling and user experience design.

## 🌍 Live Demo

🌐 **Live Application**: [Deploy to Render - Coming Soon!]  
✈️ **Book real international flights** across three continents  
📧 **Receive beautiful confirmation emails** for your bookings  
🎨 **Experience the elegant burgundy theme**  
🇺🇸🇬🇧🇳🇱🇰🇪 **Fly anywhere in the world**  

## ✨ Features

- **Advanced Search**: Multi-parameter flight search with airports, dates, and passengers
- **International Routes**: Flights spanning North America, Europe, and Africa (🇺🇸🇬🇧🇳🇱🇰🇪)
- **Dynamic Flight Results**: Real-time filtering and display of available flights
- **Complex Form Handling**: Nested passenger information forms with validation
- **Multi-step Workflow**: Search → Select → Book → Confirm process
- **Email Confirmations**: Beautiful HTML email confirmations sent to all passengers
- **Professional UI**: Airline-quality burgundy-themed responsive interface
- **PostgreSQL Database**: Production-ready database with complex relationships
- **Smart Validation**: Client and server-side validation with error handling
- **Booking Management**: Complete booking lifecycle with confirmation numbers

## 🌍 International Coverage

### 🇺🇸 United States
- **SFO** - San Francisco International Airport
- **LAX** - Los Angeles International Airport  
- **JFK** - John F. Kennedy International Airport
- **ORD** - Chicago O'Hare International Airport
- **ATL** - Hartsfield-Jackson Atlanta International Airport
- **MIA** - Miami International Airport
- **SEA** - Seattle-Tacoma International Airport
- **DEN** - Denver International Airport
- **LAS** - McCarran International Airport
- **PHX** - Phoenix Sky Harbor International Airport

### 🇪🇺 Europe
- **LHR** - London Heathrow Airport 🇬🇧
- **AMS** - Amsterdam Airport Schiphol 🇳🇱

### 🇰🇪 Africa
- **JKA** - Jomo Kenyatta International Airport, Nairobi

### ✈️ Epic Route Examples
- **Transatlantic Adventure**: JFK ↔ LHR (7-8 hours) 🌊
- **Transcontinental Journey**: SFO ↔ JFK (5.5-6 hours) 🇺🇸
- **African Safari Route**: JFK ↔ JKA (15-16 hours) 🦁
- **European Business Hop**: LHR ↔ AMS (1.5 hours) 💼
- **Pacific to Africa Epic**: SFO ↔ JKA (17-18 hours) 🌍

## 🛠️ Technologies Used

- **Ruby**: 3.4.4
- **Rails**: 8.0.2
- **PostgreSQL**: Production-grade international database
- **ActionMailer**: Professional email confirmation system
- **Letter Opener**: Development email testing
- **Advanced Forms**: `accepts_nested_attributes_for`, `fields_for`
- **Complex Queries**: Multi-table joins and filtering across continents
- **Date Handling**: Rails DateHelper and datetime manipulation
- **Responsive CSS**: Modern burgundy-themed UI with mobile support
- **International Coverage**: Multi-continent flight network

## 🏗️ Application Architecture

### Models & Relationships

```ruby
# Airport Model - International airports across 3 continents
- airport_code: string (3 chars, unique) # SFO, LHR, JKA, etc.
- name: string
- has_many :departing_flights, :arriving_flights

# Flight Model - International and domestic routes
- departure_airport_id: references
- arrival_airport_id: references
- start_datetime: datetime
- duration: integer (minutes) # 90 min domestic to 18+ hours international
- belongs_to :departure_airport, :arrival_airport
- has_many :bookings

# Booking Model - Complete booking management
- flight_id: references
- total_passengers: integer
- belongs_to :flight
- has_many :passengers
- accepts_nested_attributes_for :passengers

# Passenger Model - Individual traveler information
- booking_id: references
- name: string
- email: string (receives confirmation emails)
- belongs_to :booking
```

### Database Schema

```sql
-- Airports Table (13 international airports)
CREATE TABLE airports (
  id SERIAL PRIMARY KEY,
  airport_code VARCHAR(3) UNIQUE NOT NULL, -- SFO, LHR, JKA, etc.
  name VARCHAR NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Flights Table (4000+ international routes)
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  departure_airport_id INTEGER REFERENCES airports(id),
  arrival_airport_id INTEGER REFERENCES airports(id),
  start_datetime TIMESTAMP NOT NULL,
  duration INTEGER NOT NULL, -- Minutes: 75 (LHR-AMS) to 1080 (LAX-JKA)
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

-- Passengers Table (Email confirmation recipients)
CREATE TABLE passengers (
  id SERIAL PRIMARY KEY,
  booking_id INTEGER REFERENCES bookings(id),
  name VARCHAR NOT NULL,
  email VARCHAR NOT NULL, -- Receives beautiful confirmation emails
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## 📧 Email Confirmation System

### Beautiful HTML Email Templates
- **Professional Design**: Burgundy-themed email templates
- **Flight Details**: Complete itinerary with times and airports
- **Passenger Information**: Personalized for each traveler
- **Travel Instructions**: Airport arrival times and requirements
- **Responsive Design**: Works on desktop and mobile email clients

### Email Features
```ruby
# Automatic email sending after booking
@booking.passengers.each do |passenger|
  PassengerMailer.confirmation_email(passenger).deliver_now
end

# Email includes:
- Confirmation number
- Flight route and times  
- Passenger details
- Travel instructions
- Professional airline branding
```

## 🚀 Installation

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
   
   # Create and setup database with international routes
   rails db:create
   rails db:migrate
   rails db:seed  # Creates 13 airports and 4000+ international flights
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   Open your browser and navigate to `http://localhost:3000`

6. **Test email confirmations**
   - Book a flight with valid email addresses
   - Letter Opener will show confirmation emails in browser

## 🛫 User Journey

### Step 1: International Flight Search
- **Departure Airport**: Choose from 13 international airports
- **Arrival Airport**: Select destination across 3 continents  
- **Date**: Pick from dates with available flights (next 30 days)
- **Passengers**: Select 1-4 passengers
- **Search**: Find matching international routes

### Step 2: Flight Selection
- **View Results**: See available flights with realistic durations
- **Flight Cards**: Route, times, duration (90 min to 18+ hours), flight number
- **International Routes**: Clear continent indicators
- **Radio Selection**: Choose preferred flight
- **Book Flight**: Proceed to passenger information

### Step 3: Passenger Information
- **Flight Summary**: Review selected international flight details
- **Passenger Forms**: Dynamic forms for each passenger
- **Email Collection**: Required for confirmation emails
- **Validation**: Name and email required for each passenger
- **Cost Calculation**: Automatic pricing based on flight distance and passengers
- **Complete Booking**: Submit all passenger information

### Step 4: Booking Confirmation & Email
- **Confirmation Number**: Unique booking reference (e.g., #OA000123)
- **Flight Details**: Complete international itinerary information
- **Passenger List**: All traveler information
- **Payment Summary**: Detailed cost breakdown
- **Email Delivery**: Beautiful confirmation emails sent to each passenger
- **Travel Instructions**: International travel requirements and timing

## 🔧 Key Features Deep Dive

### Advanced International Route Management

#### Realistic Flight Durations
```ruby
route_durations = {
  # US Domestic Routes
  'SFO-LAX' => 90, 'LAX-SFO' => 90,
  'SFO-JFK' => 330, 'JFK-SFO' => 360,
  
  # Transatlantic Routes (US to Europe)
  'JFK-LHR' => 420, 'LHR-JFK' => 480,  # 7-8 hours
  'SFO-LHR' => 660, 'LHR-SFO' => 720,  # 11-12 hours
  
  # US to Africa (Epic long-haul)
  'JFK-JKA' => 900, 'JKA-JFK' => 960,   # 15-16 hours
  'SFO-JKA' => 1020, 'JKA-SFO' => 1080, # 17-18 hours
  
  # Europe to Africa
  'LHR-JKA' => 510, 'JKA-LHR' => 540,   # 8.5-9 hours
  'AMS-JKA' => 480, 'JKA-AMS' => 510,   # 8-8.5 hours
  
  # European Routes
  'LHR-AMS' => 75, 'AMS-LHR' => 80,     # 1.5 hours
}
```

#### Smart Flight Frequency
```ruby
# Popular international routes have more flights
flight_probability = case route_key
when ['JFK-LHR', 'LHR-JFK', 'SFO-LHR', 'LHR-SFO']
  0.8  # 80% chance - daily international flights
when ['LHR-JKA', 'JKA-LHR', 'AMS-JKA', 'JKA-AMS']
  0.7  # 70% chance - daily flights to African hub
when route_key.match(/JKA/) # Routes to/from Kenya
  0.3  # 30% chance - limited long-haul routes
end
```

### Professional Email System

#### HTML Email Template
```html
<div class="header">
  <h1>✈️ Flight Confirmation</h1>
  <h2>Odin Airlines</h2>
</div>

<div class="flight-route">
  <div class="airport">
    <div>JFK</div>
    <small>John F. Kennedy International Airport</small>
  </div>
  <div class="arrow">✈️</div>
  <div class="airport">
    <div>JKA</div>
    <small>Jomo Kenyatta International Airport</small>
  </div>
</div>
```

#### Multi-Passenger Email Delivery
```ruby
# Send individual emails to each passenger
@booking.passengers.each do |passenger|
  PassengerMailer.confirmation_email(passenger).deliver_now
end
```

### Complex Database Queries

#### International Flight Search Scopes
```ruby
# Flight Model Scopes
scope :departing_from, ->(airport_id) { where(departure_airport_id: airport_id) }
scope :arriving_at, ->(airport_id) { where(arrival_airport_id: airport_id) }
scope :on_date, ->(date) { where('DATE(start_datetime) = ?', date) }

# Usage for international searches
@flights = Flight.includes(:departure_airport, :arrival_airport)
                .where('start_datetime > ?', Time.current)  # Only future flights
                .departing_from(params[:departure_airport_id])
                .arriving_at(params[:arrival_airport_id])
                .on_date(params[:date])
                .order(:start_datetime)
```

## 🛣️ Routes

| HTTP Method | Path | Controller#Action | Purpose |
|-------------|------|------------------|---------|
| GET | / | flights#index | International flight search and results |
| GET | /flights | flights#index | Flight search and results |
| GET | /bookings/new | bookings#new | Passenger information form |
| POST | /bookings | bookings#create | Create booking + send emails |
| GET | /bookings/:id | bookings#show | Booking confirmation |

## 📋 Testing

### Manual Testing Checklist

#### International Flight Search
- [ ] Can search JFK → LHR (New York to London)
- [ ] Can search SFO → JKA (San Francisco to Nairobi)
- [ ] Can search LHR → AMS (London to Amsterdam)
- [ ] Flight durations show correctly (7+ hours for international)
- [ ] All 13 airports appear in dropdowns
- [ ] Date picker shows available flight dates

#### Booking & Email System
- [ ] Can book international flights with multiple passengers
- [ ] Email confirmations sent to each passenger
- [ ] HTML emails display correctly in browser (Letter Opener)
- [ ] Email includes flight details, times, and airports
- [ ] Confirmation numbers generate properly

#### International Route Validation
- [ ] Long-haul flights show realistic durations (15-18 hours)
- [ ] Short European flights show correct times (1.5 hours)
- [ ] Transatlantic flights show proper durations (7-12 hours)
- [ ] All continent combinations work

### Console Testing
```ruby
# Test international routes
jfk = Airport.find_by(airport_code: 'JFK')
jka = Airport.find_by(airport_code: 'JKA')
lhr = Airport.find_by(airport_code: 'LHR')

# Check flight availability
Flight.departing_from(jfk.id).arriving_at(jka.id).count  # US to Africa
Flight.departing_from(jfk.id).arriving_at(lhr.id).count  # US to Europe
Flight.departing_from(lhr.id).arriving_at(jka.id).count  # Europe to Africa

# Test email system
booking = Booking.includes(:passengers, flight: [:departure_airport, :arrival_airport]).first
passenger = booking.passengers.first
PassengerMailer.confirmation_email(passenger).deliver_now!
```

## 🔒 Security Considerations

### International Data Protection
- **GDPR Compliance**: Email handling for European passengers
- **Data Validation**: International name and email format validation
- **Secure Transactions**: PostgreSQL with foreign key constraints
- **Parameter Security**: Strong parameters for all international route data

### Multi-Continent Security
- **Time Zone Handling**: Proper UTC storage for international flights
- **Input Sanitization**: Protection against international character exploits
- **Email Security**: Secure SMTP for international email delivery

## 🚀 Deployment

### Render Deployment (Recommended)
```bash
# Prepare for international production deployment
echo "ruby '3.4.4'" >> Gemfile
bundle install

# Create render.yaml for international app
cat > render.yaml << EOF
databases:
  - name: flight-booker-db
    databaseName: flight_booker_production
    user: flight_booker

services:
  - type: web
    name: flight-booker
    runtime: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
EOF

# Deploy with international flight data
git push origin main
```

### Production Email Setup
```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_url_options = { 
  host: ENV['RENDER_EXTERNAL_HOSTNAME'], 
  protocol: 'https' 
}

config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',  # For international email delivery
  port: 587,
  domain: ENV['RENDER_EXTERNAL_HOSTNAME'],
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## 🌟 Future Enhancements

### International Expansion
- **More Continents**: Add Asian and Australian airports
- **Currency Support**: Multi-currency pricing for international routes
- **Time Zones**: Display local times for international flights
- **Languages**: Multi-language support for international passengers
- **Visas**: Visa requirement notifications for international travel

### Advanced Features
- **Seat Selection**: International aircraft seat maps
- **Layovers**: Multi-stop international routing
- **Alliance Partners**: Codeshare international flights
- **Loyalty Program**: Frequent flyer miles for international routes
- **Weather Integration**: Destination weather for international travel

### Business Features
- **Dynamic Pricing**: Distance-based international pricing
- **Group Bookings**: International group travel management
- **Corporate Accounts**: Business international travel
- **Travel Insurance**: International travel insurance options

## 📊 Project Statistics

🌍 **Coverage**: 3 Continents (North America, Europe, Africa)  
✈️ **Airports**: 13 International airports  
🛫 **Routes**: 4000+ International flight combinations  
📧 **Emails**: Beautiful HTML confirmations for every passenger  
⏱️ **Flight Range**: 75 minutes (LHR-AMS) to 18+ hours (SFO-JKA)  
🎨 **Theme**: Professional burgundy airline design  
💻 **Technology**: Enterprise-level Rails architecture  

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-international-feature`)
3. Commit your changes (`git commit -m 'Add amazing international feature'`)
4. Push to the branch (`git push origin feature/amazing-international-feature`)
5. Open a Pull Request

## 📚 Resources

- [Rails Guides - Form Helpers](https://guides.rubyonrails.org/form_helpers.html)
- [Rails API - accepts_nested_attributes_for](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)
- [ActionMailer Guide](https://guides.rubyonrails.org/action_mailer_basics.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Rails Guides - Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [The Odin Project](https://www.theodinproject.com/)

## 📄 License

This project is for educational purposes as part of The Odin Project curriculum.

## 🙏 Acknowledgments

- **The Odin Project** for the comprehensive advanced forms curriculum
- **PostgreSQL Community** for the powerful international database system
- **Rails Community** for excellent form handling and email capabilities
- **International Aviation** for inspiring realistic flight routes and durations
- **All developers** contributing to complex Rails application patterns

---

**Project completed as part of The Odin Project - Ruby on Rails Course**

*Taking flight with advanced Rails forms, international routes, and enterprise-level user experiences! ✈️🌍*

**Ready for takeoff to any destination worldwide! 🇺🇸🇬🇧🇳🇱🇰🇪**