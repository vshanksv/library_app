json.partial!     'api/v1/partials/book', book: @book
json.status       @status
json.borrowed_at  DateTime.now.to_s
