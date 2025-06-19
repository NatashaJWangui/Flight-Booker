class Passenger < ApplicationRecord
  belongs_to :booking

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
