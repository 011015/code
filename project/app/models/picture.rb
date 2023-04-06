class Picture < ApplicationRecord
    validates_format_of :图片,
    :multiline => true,
    :with => %r{.(jpg|gif|png)$}i,
    :message => "格式必须为 .jpg 或 .jpeg 或 .png 格式."
    validates :图片, presence: { message: "必须上传" }
    belongs_to :song, optional: true
    belongs_to :manipulator, optional: true
end
