json.array!(@redmine_keys) do |redmine_key|
  json.extract! redmine_key, :id
  json.url redmine_key_url(redmine_key, format: :json)
end
