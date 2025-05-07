json.extract! review, :id, :response, :booking_id, :created_at, :updated_at
json.url review_url(review, format: :json)
