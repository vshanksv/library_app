json.partial! 'api/v1/partials/book', book: @book
json.status       @status
json.returned_at  DateTime.now.to_s  
