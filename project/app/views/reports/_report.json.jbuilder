json.extract! report, :id, :内容, :created_at, :updated_at
json.url report_url(report, format: :json)
