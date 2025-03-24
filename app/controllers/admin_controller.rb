require 'csv'
class AdminController < ApplicationController
  before_action :authenticate_admin!

  def dashboard
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 1.month.ago.to_date
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    @bookings = Booking.where(start_date: @start_date..@end_date)

    @total_revenue = @bookings.sum { |booking| (booking.end_date - booking.start_date).to_i * booking.car.price_per_day + (booking.end_date - booking.start_date).to_i * booking.insurance_per_day }
    @total_car_price = @bookings.sum { |booking| (booking.end_date - booking.start_date).to_i * booking.car.price_per_day }
    @total_insurance = @bookings.sum { |booking| (booking.end_date - booking.start_date).to_i * booking.insurance_per_day }

    @monthly_data = @bookings.group_by { |booking| booking.start_date.beginning_of_month }
                             .map do |month, bookings| 
                               {
                                 month: month.strftime('%B %Y'),
                                 total_rent: bookings.sum { |booking| (booking.end_date - booking.start_date).to_i * booking.car.price_per_day }.abs,
                                 total_insurance: bookings.sum { |booking| (booking.end_date - booking.start_date).to_i * booking.insurance_per_day }.abs
                               }
                             end

  @total_revenue = @total_revenue.abs
  @total_car_price = @total_car_price.abs
  @total_insurance = @total_insurance.abs
  end

  def send_csv
    # Generate the CSV content
    @bookings = Booking.where(created_at: @start_date..@end_date) # Adjust as per your logic

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Car Name", "Pick Up Spot", "Start Date", "End Date", "Total Cost"]
      @bookings.each do |booking|
        csv << [booking.car.model, booking.pick_up_spot, booking.start_date, booking.end_date, 
                (booking.car.price_per_day * (booking.end_date - booking.start_date).to_i + booking.insurance_per_day * (booking.end_date - booking.start_date).to_i).abs]
      end
    end

    # Send the email
    UserMailer.send_csv_email(current_user.email, csv_data).deliver_now

    # Redirect back to the dashboard with a success message
    redirect_to admin_dashboard_path, notice: 'CSV has been sent to your email.'
  end


  def authenticate_admin!
    current_user.permission == 'ADMIN'
  end
end
