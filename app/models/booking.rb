class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :user
  has_many :reviews, dependent: :destroy
end
