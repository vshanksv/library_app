json.books @result[:books] do |book|
  json.partial! 'api/v1/partials/book', book: Book.new(book)
end

json.meta do
  json.current_page @result[:current_page]
  json.total_pages @result[:total_pages]
  json.total_count @result[:total_count]
end