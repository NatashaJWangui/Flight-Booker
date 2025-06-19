class Booking < ApplicationRecord
  belongs_to :flight
  has_many :passengers, dependent: :destroy

  accepts_nested_attributes_for :passengers

  validates :total_passengers, presence: true, numericality: { in: 1..4 }
  validates :passengers, length: { minimum: 1 }

  def total_cost
    # Simple pricing: $200 base + $50 per hour of flight
    base_price = 200
    duration_price = (flight.duration / 60.0 * 50).round
    (base_price + duration_price) * total_passengers
  end
end
