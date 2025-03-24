class CarMailer < ApplicationMailer
  default from: 'no-reply@example.com'  # Update the 'from' email address as needed

  def csv_uploaded
    @user = params[:user]            # User receiving the email
    @file_url = params[:file_url]    # URL of the file uploaded in ActiveStorage

    # Email with text format
    mail(to: @user.email, subject: "Your CSV File is Ready to Download") do |format|
      format.text { render plain: "Hello #{@user.email},\n\nYour CSV file is ready for download. Click the link below to download it:\n\n#{@file_url}" }
      
      # Email with HTML format
      format.html { render html: "<p>Hello #{@user.email},</p><p>Your CSV file is ready for download. Click the link below to download it:</p><a href='#{@file_url}'>Download CSV</a>".html_safe }
    end
  end
end
