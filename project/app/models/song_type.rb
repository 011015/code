class SongType < ApplicationRecord
    validates :名称, presence: { message: "必须填" }
    has_many :songs, dependent: :nullify
end
