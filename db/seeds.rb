# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Clear existing data
# Clear existing data
Passenger.destroy_all
Booking.destroy_all
Flight.destroy_all
Airport.destroy_all

# Create airports with real data
airports = Airport.create!([
  { airport_code: 'SFO', name: 'San Francisco International Airport' },
  { airport_code: 'LAX', name: 'Los Angeles International Airport' },
  { airport_code: 'JKA', name: 'Jomo Kenyatta International Airport' },
  { airport_code: 'JFK', name: 'John F. Kennedy International Airport' },
  { airport_code: 'ORD', name: 'Chicago O\'Hare International Airport' },
  { airport_code: 'MIA', name: 'Miami International Airport' },
  { airport_code: 'SEA', name: 'Seattle-Tacoma International Airport' },
  { airport_code: 'DEN', name: 'Denver International Airport' },
  { airport_code: 'ATL', name: 'Hartsfield-Jackson Atlanta International Airport' },
  { airport_code: 'LAS', name: 'McCarran International Airport' },
  { airport_code: 'PHX', name: 'Phoenix Sky Harbor International Airport' }

])

puts "Created #{Airport.count} airports"

# Create more realistic flight schedule
departure_times = [
  { hour: 6, minute: 0 },   # 6:00 AM
  { hour: 8, minute: 30 },  # 8:30 AM
  { hour: 11, minute: 15 }, # 11:15 AM
  { hour: 14, minute: 45 }, # 2:45 PM
  { hour: 17, minute: 30 }, # 5:30 PM
  { hour: 20, minute: 15 }  # 8:15 PM
]

# Flight duration based on typical routes (in minutes)
route_durations = {
  'SFO-LAX' => 90, 'LAX-SFO' => 90,
  'SFO-JFK' => 330, 'JFK-SFO' => 360,
  'LAX-JFK' => 310, 'JFK-LAX' => 340,
  'ORD-MIA' => 180, 'MIA-ORD' => 185,
  'SEA-ATL' => 260, 'ATL-SEA' => 270,
  'DEN-LAS' => 105, 'LAS-DEN' => 110
}

# Create flights for the next 30 days
flight_count = 0
30.times do |day|
  date = Date.current + day.days

  # Skip some days randomly to make it more realistic
  next if day > 0 && rand < 0.1  # 10% chance to skip a day

  airports.each do |departure_airport|
    airports.each do |arrival_airport|
      next if departure_airport == arrival_airport

      route_key = "#{departure_airport.airport_code}-#{arrival_airport.airport_code}"
      duration = route_durations[route_key] || (120 + rand(180)) # Default 2-5 hours

      # Popular routes have more flights
      num_flights = case route_key
      when 'SFO-LAX', 'LAX-SFO', 'SFO-JFK', 'JFK-SFO', 'LAX-JFK', 'JFK-LAX'
        rand < 0.8 ? departure_times.sample(rand(2..4)) : []
      when 'ORD-MIA', 'MIA-ORD', 'SEA-ATL', 'ATL-SEA'
        rand < 0.6 ? departure_times.sample(rand(1..3)) : []
      else
        rand < 0.3 ? departure_times.sample(rand(1..2)) : []
      end

      num_flights.each do |time_slot|
        start_datetime = date.beginning_of_day + time_slot[:hour].hours + time_slot[:minute].minutes

        # Skip past flights for today
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

puts "Created #{flight_count} flights"
puts "Flight dates from #{Flight.minimum(:start_datetime)&.to_date} to #{Flight.maximum(:start_datetime)&.to_date}"

# Create some sample bookings for demonstration
if Flight.count > 0
  sample_flights = Flight.limit(3)

  sample_flights.each_with_index do |flight, index|
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