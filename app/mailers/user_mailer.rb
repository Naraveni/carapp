class UserMailer < ApplicationMailer
  def send_csv_email(email, csv_data)
    @csv_data = csv_data
    attachments['bookings.csv'] = { mime_type: 'text/csv', content: @csv_data }
    mail(to: email, subject: 'CSV of Bookings')
  end
end