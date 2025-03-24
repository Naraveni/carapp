class AddCarIdToBookings < ActiveRecord::Migration[7.1]
  def change
    add_reference :bookings, :car, foreign_key: true
  end
end
