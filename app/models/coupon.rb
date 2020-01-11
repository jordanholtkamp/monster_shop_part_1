class Coupon < ApplicationRecord
    validates_presence_of :name
    validates_presence_of :code
    validates_presence_of :value_off

    has_many :orders
end 