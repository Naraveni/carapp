class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :insurance_per_day
      t.string :pick_up_spot
      t.timestamps
    end
  end
end
