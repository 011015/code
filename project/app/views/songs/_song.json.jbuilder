json.extract! song, :id, :演唱, :作词, :作曲, :created_at, :updated_at
json.url song_url(song, format: :json)
