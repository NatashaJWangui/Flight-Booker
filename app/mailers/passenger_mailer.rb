class PassengerMailer < ApplicationMailer
  default from: "bookings@njwairlines.com"

  def confirmation_email(passenger)
    @passenger = passenger
    @booking = passenger.booking
    @flight = @booking.flight

    mail(
      to: @passenger.email,
      subject: "✈️ Flight Confirmation - #{@flight.departure_airport.airport_code} to #{@flight.arrival_airport.airport_code}"
    )
  end
end
