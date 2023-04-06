class Notice < ApplicationRecord
    belongs_to :whistleblower, optional: true, class_name: "Manipulator"
    belongs_to :manipulator, optional: true
end
