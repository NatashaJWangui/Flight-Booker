class Airport < ApplicationRecord
  has_many :departing_flights, class_name: "Flight", foreign_key: "departure_airport_id"
  has_many :arriving_flights, class_name: "Flight", foreign_key: "arrival_airport_id"

  validates :airport_code, presence: true, uniqueness: true, length: { is: 3 }
  validates :name, presence: true

  def to_s
    "#{airport_code} - #{name}"
  end
end
