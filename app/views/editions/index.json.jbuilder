json.array!(@editions) do |edition|
  json.extract! edition, :id, :oclc, :xoclcs, :best_match
  json.url edition_url(edition, format: :json)
end
