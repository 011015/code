class Comment < ApplicationRecord
    validates :内容, presence: { message: "必须填" }
    belongs_to :song
    belongs_to :manipulator, class_name: "Manipulator", foreign_key: "com_manipulator_id"
    has_many :reports, dependent: :delete_all
end
