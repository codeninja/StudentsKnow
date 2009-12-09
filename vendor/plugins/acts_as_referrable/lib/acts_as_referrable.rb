# ActsAsReferrable
module Mwd
  module Acts #:nodoc:
    module Referrable #:nodoc:
      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_referrable
          has_many :referrals, :as => :referrable, :dependent => :destroy
          include Mwd::Acts::Referrable::InstanceMethods
          extend Mwd::Acts::Referrable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods

      end
      
      # This module contains instance methods
      module InstanceMethods
        
        # Create Referral and return referral code for provided user, or defaulting to owning user
        def referral_code(referring_user=nil)
          referring_user ||= user
          unless (ref = referrals.find_by_user_id(referring_user.id))
            ref = referrals.create(:code => Digest::SHA1.hexdigest(Time.now.to_s).to_s, :user_id => referring_user.id )
            reload
          end
          return ref.code
        end

        def referrals_by(referring_user)
            hits.count(:conditions => ['kind = ?', referral_code(referring_user)])
        end
        
        # Create hit based on either code or user
        def referral_hit(referring_user_or_code=nil,viewing_user_id=0)
          if referring_user_or_code.is_a?(String)
            if (ref_code = referrals.find_by_code(referring_user_or_code))
              hit(ref_code.code, viewing_user_id)
            else
              referral_hit(nil, viewing_user_id)
            end
          else
            ref_code = referral_code(referring_user_or_code)
            hit(ref_code, viewing_user_id) 
          end
        end
        
      end
      
    end
  end
end
