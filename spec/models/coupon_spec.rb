require 'rails_helper'

describe Coupon, type: :model do
    describe 'validations' do 
        it { should validate_presence_of :name }
        it { should validate_presence_of :code }
        it { should validate_presence_of :value_off }
    end 
end