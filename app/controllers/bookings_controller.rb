class BookingsController < ApplicationController
  before_action :set_car, only: %i[new create]
  before_action :set_booking, only: %i[edit update]

  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id
    if @booking.save
      @car = @booking.car
      @car.update(status: 1) # Update car status to "booked"

      # Send confirmation email
      BookingMailer.send_confirmation_email(@booking).deliver_now

      redirect_to bookings_path, notice: 'Booking created successfully.'
    else
      render :new
    end
  end

  def index
    @bookings = if params[:status] == 'pending'
                  Booking.all.includes(:reviews)
                else
                  current_user.bookings.includes(:reviews)
                end
    render :index
  end

  def edit
    @booking = Booking.find(params['id'])
    @car = Car.find(@booking.car_id)
  end

  def update
    @booking = Booking.find(params[:id])

    # Only update the booking if it was successfully updated
    if @booking.update(booking_params)
      # Send an email notification to the user
      BookingMailer.send_update_notification(@booking).deliver_now

      redirect_to bookings_path, notice: 'Booking updated successfully.'
    else
      render :edit
    end
  end

  private

  def set_car
    @car = Car.find(params[:car_id]) if params[:car_id]
    @car = Car.find(params[:booking][:car_id]) if params[:booking] && params[:booking][:car_id]
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date, :insurance_per_day, :pick_up_spot, :car_id)
  end
end
