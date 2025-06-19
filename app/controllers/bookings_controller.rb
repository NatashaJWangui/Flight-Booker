class BookingsController < ApplicationController
  before_action :validate_flight_selection, only: [:new]

  def new
    @flight = Flight.find(params[:flight_id])
    @num_passengers = params[:num_passengers].to_i

    # Validate passenger count
    unless (1..4).include?(@num_passengers)
      redirect_to flights_path, alert: "Invalid number of passengers selected."
      return
    end

    @booking = Booking.new(flight: @flight, total_passengers: @num_passengers)

    # Create blank passenger objects for the form
    @num_passengers.times { @booking.passengers.build }
  end

  def create
    @booking = Booking.new(booking_params)
    @flight = @booking.flight

    if @booking.save
      redirect_to @booking, notice: "Booking was successfully created!"
    else
      @num_passengers = @booking.total_passengers
      # Rebuild passenger objects if validation fails
      while @booking.passengers.length < @num_passengers
        @booking.passengers.build
      end
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking = Booking.find(params[:id])
  end

  private

  def validate_flight_selection
    unless params[:flight_id].present?
      redirect_to flights_path, alert: "Please select a flight first."
    end
  end

  def booking_params
    params.require(:booking).permit(:flight_id, :total_passengers,
                                   passengers_attributes: [ :name, :email ])
  end
end