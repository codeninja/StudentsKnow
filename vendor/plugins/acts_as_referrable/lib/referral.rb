class Referral < ActiveRecord::Base
  belongs_to :referrable, :polymorphic => true
  belongs_to :user
end