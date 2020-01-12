class Coupon < ApplicationRecord
    validates_presence_of :name
    validates_presence_of :code
    validates_presence_of :value_off

    validates_uniqueness_of :name
    validates_uniqueness_of :code

    validates_numericality_of :value_off

    has_many :orders
    belongs_to :merchant
end 