class Flight < ApplicationRecord
  belongs_to :departure_airport, class_name: "Airport"
  belongs_to :arrival_airport, class_name: "Airport"
  has_many :bookings, dependent: :destroy

  validates :start_datetime, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }

  # Scopes for searching
  scope :departing_from, ->(airport_id) { where(departure_airport_id: airport_id) }
  scope :arriving_at, ->(airport_id) { where(arrival_airport_id: airport_id) }
  scope :on_date, ->(date) { where("DATE(start_datetime) = ?", date) }

  def departure_date
    start_datetime.to_date
  end

  def formatted_departure_time
    start_datetime.strftime("%I:%M %p")
  end

  def formatted_arrival_time
    arrival_time.strftime("%I:%M %p")
  end

  def arrival_time
    start_datetime + duration.minutes
  end

  def duration_formatted
    hours = duration / 60
    minutes = duration % 60
    "#{hours}h #{minutes}m"
  end
end
