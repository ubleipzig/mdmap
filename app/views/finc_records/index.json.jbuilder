json.array!(@finc_records) do |finc_record|
  json.extract! finc_record, :id
  json.url finc_record_url(finc_record, format: :json)
end
