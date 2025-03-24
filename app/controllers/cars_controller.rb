# app/controllers/cars_controller.rb
require 'csv'
class CarsController < ApplicationController
  before_action :set_car, only: %i[show edit update destroy]

  def index
    @cars = Car.where(status: 0)

    # Apply filters if parameters are provided
    if params[:model].present?
      @cars = @cars.where("model LIKE ?", "%#{params[:model]}%")
    end

    if params[:min_price].present?
      @cars = @cars.where("price_per_day >= ?", params[:min_price])
    end

    if params[:max_price].present?
      @cars = @cars.where("price_per_day <= ?", params[:max_price])
    end

    if params[:manufactured_year].present?
      @cars = @cars.where("EXTRACT(YEAR FROM manufactured_year) = ?", params[:manufactured_year].to_i)
    end

    # Get unique manufactured years
    @manufactured_years = Car.pluck(:manufactured_year).uniq.map { |date| date.strftime("%Y") }
  end

  def new
    @car = Car.new
  end

  def download_csv_template
    # Prepare the CSV headers
    headers = ['model', 'manufactured_year', 'price_per_day', 'name']
    
    # Generate the CSV content
    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers # Add the header row
    end

    # Send the CSV file as an attachment
    send_data csv_data, filename: 'cars_template.csv', type: 'text/csv', disposition: 'attachment'
  end
  
  def upload_csv
    if params[:file].present?
      file = params[:file]
      updated_csv = CSV.generate(headers: true) do |csv|
        # Add the header row with a new "Status" column
        csv << ['model', 'manufactured_year', 'price_per_day', 'name', 'status']
  
        # Read the uploaded CSV file
        CSV.foreach(file.path, headers: true, encoding: 'iso-8859-1:utf-8') do |row|
          # Create a new Car record and track success or error
          car = Car.new(
            model: row["model"],
            manufactured_year: Date.new(row["manufactured_year"].to_i, 1, 1),
            price_per_day: row["price_per_day"],
            name: row["name"],
            status: 0
          )
  
          if car.valid?
            car.save
            csv << row.to_h.values.push('Success')  # Add Success to the Status column
          else
            csv << row.to_h.values.push("Error: #{car.errors.full_messages.join(', ')}")  # Add error messages to Status column
          end
        end
      end
  
      # Create a file in ActiveStorage
      csv_file = StringIO.new(updated_csv)
      csv_file.class.class_eval { attr_accessor :original_filename, :content_type }
      current_time = Time.now.strftime("%Y-%m-%d_%H-%M-%S") # Format: YYYY-MM-DD_HH-MM-SS
      csv_file.original_filename = "cars_with_status_#{current_time}.csv"
      csv_file.content_type = "text/csv"
  
      # Attach the file to the current user (or any other model you prefer)
      user = current_user  # Replace this with the appropriate user model if necessary
      user.cars_csv.attach(io: csv_file, filename: "cars_with_status.csv", content_type: "text/csv")
  
      # Send the email with the file link
      CarMailer.with(user: user, file_url: rails_blob_url(user.cars_csv)).csv_uploaded.deliver_now
  
      flash[:success] = "CSV processed successfully! The file is ready for download."
      redirect_to cars_path
    else
      flash[:error] = "Please upload a valid CSV file."
    end
  end
  
  
  
  def create
    @car = Car.new(car_params)
    if params[:car][:image]
      @car.name = params[:car][:image].original_filename
    end
    if @car.save
      redirect_to cars_path, notice: 'Car was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @car.update(car_params)
      render :index, notice: 'Car was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @car.destroy
    render :index , notice: 'Car was successfully deleted.'
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def car_params
    params.require(:car).permit(:model, :manufactured_year, :price_per_day, :image)
  end

  def upload
    # This renders upload.html.erb
  end
end
