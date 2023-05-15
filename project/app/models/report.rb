class Report < ApplicationRecord
    validates :内容, presence: { message: "必须填" }
    belongs_to :manipulator
    belongs_to :comment, optional: true
end
