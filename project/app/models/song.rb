class Song < ApplicationRecord
    validates :名称, :作词, :作曲, presence: { message: "必须填" }
    belongs_to :manipulator, class_name: "Manipulator", foreign_key: "manipulator_id"
    belongs_to :song_type, optional: true
    has_many :pictures, dependent: :delete_all
    has_many :comments, dependent: :delete_all
end
