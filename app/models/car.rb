class Car < ApplicationRecord
  has_one_attached :image
  has_many :bookings
  enum status: { available: 0, booked: 1, under_maintenance: 2 }
  validates :model, presence: true
  validates :manufactured_year, presence: true
  validates :price_per_day, presence: true
  validates :name, presence: true
  
end
