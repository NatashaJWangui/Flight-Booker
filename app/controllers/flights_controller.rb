class FlightsController < ApplicationController
  def index
    @airports = Airport.all.order(:airport_code)
    @flight_dates = Flight.distinct.pluck(:start_datetime).map(&:to_date).uniq.sort
    @passenger_options = (1..4).map { |i| [i, i] }

    if params[:departure_airport_id].present?
      @flights = Flight.includes(:departure_airport, :arrival_airport)
                      .departing_from(params[:departure_airport_id])
                      .arriving_at(params[:arrival_airport_id])
                      .on_date(params[:date])
                      .order(:start_datetime)
    end
  end
end
