require 'rails_helper'

describe Coupon, type: :model do
    describe 'validations' do 
        it { should validate_presence_of :name }
        it { should validate_presence_of :code }
        it { should validate_presence_of :value_off }
        it { should validate_uniqueness_of :name }
        it { should validate_uniqueness_of :code }
        it { should validate_numericality_of :value_off }
      end 

    describe 'relationships' do 
        it { should have_many :orders }
        it { should belong_to :merchant }
    end 
end