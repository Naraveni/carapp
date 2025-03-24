# app/mailers/booking_mailer.rb
class BookingMailer < ApplicationMailer
  default from: 'no-reply@example.com' # Set the sender email

  def send_confirmation_email(booking)
    @booking = booking
    @user = booking.user
    @car = booking.car

    mail(to: @user.email, subject: "Booking Confirmation for #{@car.model}")
  end

  def send_update_notification(booking)
    @booking = booking
    @user = booking.user
    @car = booking.car

    mail(to: @user.email, subject: "Your Booking for #{@car.model} has been Updated")
  end
end
