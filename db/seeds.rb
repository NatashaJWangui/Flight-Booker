# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
Passenger.destroy_all
Booking.destroy_all
Flight.destroy_all
Airport.destroy_all

# Create airports including Jomo Kenyatta International Airport
airports = Airport.create!([
  { airport_code: 'SFO', name: 'San Francisco International Airport' },
  { airport_code: 'LAX', name: 'Los Angeles International Airport' },
  { airport_code: 'JKA', name: 'Jomo Kenyatta International Airport' },  # Nairobi, Kenya 🇰🇪
  { airport_code: 'JFK', name: 'John F. Kennedy International Airport' },
  { airport_code: 'ORD', name: 'Chicago O\'Hare International Airport' },
  { airport_code: 'MIA', name: 'Miami International Airport' },
  { airport_code: 'SEA', name: 'Seattle-Tacoma International Airport' },
  { airport_code: 'DEN', name: 'Denver International Airport' },
  { airport_code: 'ATL', name: 'Hartsfield-Jackson Atlanta International Airport' },
  { airport_code: 'LAS', name: 'McCarran International Airport' },
  { airport_code: 'PHX', name: 'Phoenix Sky Harbor International Airport' },
  { airport_code: 'LHR', name: 'London Heathrow Airport' },
  { airport_code: 'AMS', name: 'Amsterdam Airport Schiphol' }
])

puts "Created #{Airport.count} airports including Nairobi (JKA), Heathrow, and Amsterdam"

# Create flights for the next 30 days
departure_times = [
  { hour: 6, minute: 0 },   # 6:00 AM
  { hour: 8, minute: 30 },  # 8:30 AM
  { hour: 11, minute: 15 }, # 11:15 AM
  { hour: 14, minute: 45 }, # 2:45 PM
  { hour: 17, minute: 30 }, # 5:30 PM
  { hour: 20, minute: 15 }, # 8:15 PM
  { hour: 23, minute: 45 }  # 11:45 PM (for international flights)
]

# Flight duration based on typical routes (in minutes)
route_durations = {
  # US Domestic Routes
  'SFO-LAX' => 90, 'LAX-SFO' => 90,
  'SFO-JFK' => 330, 'JFK-SFO' => 360,
  'LAX-JFK' => 310, 'JFK-LAX' => 340,
  'ORD-MIA' => 180, 'MIA-ORD' => 185,
  'SEA-ATL' => 260, 'ATL-SEA' => 270,
  'DEN-LAS' => 105, 'LAS-DEN' => 110,
  'SFO-SEA' => 120, 'SEA-SFO' => 125,
  'LAX-LAS' => 75, 'LAS-LAX' => 80,
  'JFK-MIA' => 190, 'MIA-JFK' => 195,
  'ORD-DEN' => 135, 'DEN-ORD' => 140,

  # Transatlantic Routes (US to Europe)
  'JFK-LHR' => 420, 'LHR-JFK' => 480,  # 7-8 hours
  'SFO-LHR' => 660, 'LHR-SFO' => 720,  # 11-12 hours
  'LAX-LHR' => 650, 'LHR-LAX' => 710,  # 10.5-11.5 hours
  'ORD-LHR' => 480, 'LHR-ORD' => 540,  # 8-9 hours
  'MIA-LHR' => 510, 'LHR-MIA' => 570,  # 8.5-9.5 hours

  # US to Amsterdam
  'JFK-AMS' => 450, 'AMS-JFK' => 510,  # 7.5-8.5 hours
  'SFO-AMS' => 690, 'AMS-SFO' => 750,  # 11.5-12.5 hours
  'LAX-AMS' => 680, 'AMS-LAX' => 740,  # 11-12 hours
  'ORD-AMS' => 510, 'AMS-ORD' => 570,  # 8.5-9.5 hours
  'ATL-AMS' => 480, 'AMS-ATL' => 540,  # 8-9 hours

  # US to Nairobi, Kenya (JKA) - Long-haul routes
  'JFK-JKA' => 900, 'JKA-JFK' => 960,   # 15-16 hours
  'SFO-JKA' => 1020, 'JKA-SFO' => 1080, # 17-18 hours
  'LAX-JKA' => 1080, 'JKA-LAX' => 1140, # 18-19 hours
  'ORD-JKA' => 930, 'JKA-ORD' => 990,   # 15.5-16.5 hours
  'ATL-JKA' => 900, 'JKA-ATL' => 960,   # 15-16 hours
  'MIA-JKA' => 930, 'JKA-MIA' => 990,   # 15.5-16.5 hours

  # Europe to Nairobi, Kenya (JKA)
  'LHR-JKA' => 510, 'JKA-LHR' => 540,   # 8.5-9 hours
  'AMS-JKA' => 480, 'JKA-AMS' => 510,   # 8-8.5 hours

  # European Routes
  'LHR-AMS' => 75, 'AMS-LHR' => 80,     # 1.5 hours

  # Amsterdam to other US cities
  'AMS-SEA' => 600, 'SEA-AMS' => 660,   # 10-11 hours
  'AMS-DEN' => 570, 'DEN-AMS' => 630,   # 9.5-10.5 hours

  # Additional routes through hubs (connecting flights)
  'SEA-JKA' => 1050, 'JKA-SEA' => 1110, # 17.5-18.5 hours
  'DEN-JKA' => 960, 'JKA-DEN' => 1020   # 16-17 hours
}

flight_count = 0

# Create flights for the next 30 days
30.times do |day|
  date = Date.current + day.days

  airports.each do |departure_airport|
    airports.each do |arrival_airport|
      next if departure_airport == arrival_airport

      route_key = "#{departure_airport.airport_code}-#{arrival_airport.airport_code}"
      duration = route_durations[route_key] || (120 + rand(180)) # Default 2-5 hours

      # Define flight probabilities based on route popularity
      flight_probability = case
      # Major US domestic routes (high frequency)
      when [ 'SFO-LAX', 'LAX-SFO', 'SFO-JFK', 'JFK-SFO', 'LAX-JFK', 'JFK-LAX' ].include?(route_key)
        0.9  # 90% chance - multiple daily flights

      # Major international routes (medium-high frequency)
      when [ 'JFK-LHR', 'LHR-JFK', 'SFO-LHR', 'LHR-SFO', 'JFK-AMS', 'AMS-JFK' ].include?(route_key)
        0.8  # 80% chance - daily flights

      # Europe to Kenya routes (major African gateway)
      when [ 'LHR-JKA', 'JKA-LHR', 'AMS-JKA', 'JKA-AMS' ].include?(route_key)
        0.7  # 70% chance - daily flights to/from major African hub

      # US to Kenya routes (limited but important)
      when [ 'JFK-JKA', 'JKA-JFK', 'ATL-JKA', 'JKA-ATL' ].include?(route_key)
        0.5  # 50% chance - several weekly flights

      # Secondary international routes (medium frequency)
      when route_key.match(/LAX-(LHR|AMS)/) || route_key.match(/(LHR|AMS)-LAX/) ||
           route_key.match(/ORD-(LHR|AMS)/) || route_key.match(/(LHR|AMS)-ORD/)
        0.6  # 60% chance - several weekly flights

      # Other US to Kenya routes (less frequent)
      when route_key.match(/JKA/) && ![ 'LHR', 'AMS' ].any? { |code| route_key.include?(code) }
        0.3  # 30% chance - less frequent long-haul routes

      # European short-haul (high frequency)
      when [ 'LHR-AMS', 'AMS-LHR' ].include?(route_key)
        0.9  # 90% chance - multiple daily flights

      # Other US domestic routes
      when !route_key.match(/(LHR|AMS|JKA)/)  # No international airports
        0.5  # 50% chance - regular domestic routes

      # Long-haul routes from smaller US cities to Europe
      else
        0.3  # 30% chance - less frequent routes
      end

      if rand < flight_probability
        # Determine number of flights based on route type
        num_flights = case
        when [ 'SFO-LAX', 'LAX-SFO', 'LHR-AMS', 'AMS-LHR' ].include?(route_key)
          rand(3..6)  # 3-6 flights per day (high frequency)
        when [ 'JFK-LHR', 'LHR-JFK', 'JFK-AMS', 'AMS-JFK' ].include?(route_key)
          rand(2..4)  # 2-4 flights per day (international hubs)
        when [ 'LHR-JKA', 'JKA-LHR', 'AMS-JKA', 'JKA-AMS' ].include?(route_key)
          rand(1..2)  # 1-2 flights per day (Europe-Africa)
        when route_key.match(/JKA/)  # Routes to/from Kenya
          rand(1..2)  # 1-2 flights per day (limited long-haul)
        when route_key.match(/(LHR|AMS)/)  # Other international routes
          rand(1..2)  # 1-2 flights per day
        else
          rand(1..3)  # 1-3 flights per day (domestic)
        end

        selected_times = departure_times.sample(num_flights)

        selected_times.each do |time_slot|
          start_datetime = date.beginning_of_day + time_slot[:hour].hours + time_slot[:minute].minutes

          # Skip flights that are in the past
          next if start_datetime < Time.current

          Flight.create!(
            departure_airport: departure_airport,
            arrival_airport: arrival_airport,
            start_datetime: start_datetime,
            duration: duration
          )
          flight_count += 1
        end
      end
    end
  end
end

puts "Created #{flight_count} flights"
puts "Flight dates from #{Flight.minimum(:start_datetime)&.to_date} to #{Flight.maximum(:start_datetime)&.to_date}"

# Create some sample bookings for demonstration
if Flight.count > 0
  puts "Creating sample bookings..."

  # Create bookings for different types of routes including Kenya
  sample_flights = [
    Flight.joins(:departure_airport, :arrival_airport)
          .where(airports: { airport_code: 'SFO' })
          .where(arrival_airports_flights: { airport_code: 'LAX' })
          .first,
    Flight.joins(:departure_airport, :arrival_airport)
          .where(airports: { airport_code: 'JFK' })
          .where(arrival_airports_flights: { airport_code: 'LHR' })
          .first,
    Flight.joins(:departure_airport, :arrival_airport)
          .where(airports: { airport_code: 'SFO' })
          .where(arrival_airports_flights: { airport_code: 'AMS' })
          .first,
    Flight.joins(:departure_airport, :arrival_airport)
          .where(airports: { airport_code: 'LHR' })
          .where(arrival_airports_flights: { airport_code: 'JKA' })
          .first,
    Flight.joins(:departure_airport, :arrival_airport)
          .where(airports: { airport_code: 'JFK' })
          .where(arrival_airports_flights: { airport_code: 'JKA' })
          .first
  ].compact

  sample_flights.each_with_index do |flight, index|
    next unless flight

    booking = Booking.create!(
      flight: flight,
      total_passengers: rand(1..3)
    )

    booking.total_passengers.times do |passenger_num|
      Passenger.create!(
        booking: booking,
        name: "Sample Passenger #{index + 1}.#{passenger_num + 1}",
        email: "passenger#{index + 1}#{passenger_num + 1}@example.com"
      )
    end
  end

  puts "Created #{Booking.count} sample bookings with #{Passenger.count} passengers"
end

puts "\n✈️ Database seeded successfully with international routes including Kenya!"
puts "=" * 60
puts "Airports: #{Airport.count}"
puts "  - US Airports: #{Airport.where.not(airport_code: [ 'LHR', 'AMS', 'JKA' ]).count}"
puts "  - London Heathrow (LHR): ✅"
puts "  - Amsterdam Schiphol (AMS): ✅"
puts "  - Jomo Kenyatta International, Nairobi (JKA): ✅ 🇰🇪"
puts "Flights: #{Flight.count}"
puts "  - Domestic US flights: #{Flight.joins(:departure_airport, :arrival_airport).where.not(airports: { airport_code: [ 'LHR', 'AMS', 'JKA' ] }).where.not(arrival_airports_flights: { airport_code: [ 'LHR', 'AMS', 'JKA' ] }).count}"
puts "  - Transatlantic flights (US-Europe): #{Flight.joins(:departure_airport, :arrival_airport).where('(airports.airport_code IN (?) AND arrival_airports_flights.airport_code IN (?)) OR (airports.airport_code IN (?) AND arrival_airports_flights.airport_code IN (?))', [ 'SFO', 'LAX', 'JFK', 'ORD', 'MIA', 'SEA', 'DEN', 'ATL', 'LAS', 'PHX' ], [ 'LHR', 'AMS' ], [ 'LHR', 'AMS' ], [ 'SFO', 'LAX', 'JFK', 'ORD', 'MIA', 'SEA', 'DEN', 'ATL', 'LAS', 'PHX' ]).count}"
puts "  - Africa routes (to/from Kenya): #{Flight.joins(:departure_airport, :arrival_airport).where('airports.airport_code = ? OR arrival_airports_flights.airport_code = ?', 'JKA', 'JKA').count}"
puts "  - European routes: #{Flight.joins(:departure_airport, :arrival_airport).where('airports.airport_code IN (?) AND arrival_airports_flights.airport_code IN (?)', [ 'LHR', 'AMS' ], [ 'LHR', 'AMS' ]).count}"
puts "Bookings: #{Booking.count}"
puts "Passengers: #{Passenger.count}"
puts "\n🌍 Now featuring routes to three continents: North America, Europe, and Africa!"
puts "🇺🇸 🇬🇧 🇳🇱 🇰🇪"
