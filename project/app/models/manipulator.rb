class Manipulator < ApplicationRecord
    validates :名称, :密码, presence: { message: "必须填" }
    has_one :头像, class_name: "Picture", dependent: :destroy
    has_many :reports, dependent: :delete_all
    has_many :comments, dependent: :delete_all, class_name: "Comment", foreign_key: "com_manipulator_id"
    has_many :songs, dependent: :destroy, class_name: "Song", foreign_key: "manipulator_id"
    has_many :notices, dependent: :delete_all, class_name: "Notice", foreign_key: "whistleblower_id"
    has_many :messages, dependent: :delete_all, class_name: "Notice", foreign_key: "manipulator_id"
end
