# ActsAsCommentable
module Mwd
  module Acts #:nodoc:
    module Rateable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_rateable
          has_many :ratings, :as => :rateable, :dependent => :destroy
          include Mwd::Acts::Rateable::InstanceMethods
          extend Mwd::Acts::Rateable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        
          # Returns top rated with optional limit
          def top_rated(limit=nil)
            mytable = self.table_name
            myclass = self.class_name
            self.find_by_sql(sanitize_sql("
              SELECT #{mytable}.*, AVG(ratings.value) AS avg_rating FROM #{mytable}, ratings 
                WHERE #{mytable}.id = ratings.rateable_id AND ratings.rateable_type = '#{myclass}' 
                GROUP BY #{mytable}.id
                ORDER BY avg_rating DESC
                #{limit.is_a?(Fixnum) ? "LIMIT #{limit}" : ""  }"))
          end
          
          def to_letter_grade(r)
            return "UR" if r.to_i <= 0
            letter = ['F','D','C','B','A','A'][r.to_i]
            if r.to_i == 5
              letter_mod = '+'
            elsif r.to_i < 1
              letter_mod = ''
            else
              letter_mod = ['-','','+'][((r - r.to_i) * 3).to_i]
            end
            return letter + letter_mod
          end

      end
      
      # This module contains instance methods
      module InstanceMethods
        # Have the object rated anonymously, or by user, return NIL if failure
        def rate(value,user=nil)
          raise "invalid rating" unless (0..5).to_a.include?(value)
          if user.nil?
            r = ratings.new(:value => value, :anonymous => true)
          else
            user_id = (user.nil? ? nil : user.id)
            r = ratings.new(:value => value, :user_id => user_id)
          end
          return (r.save ? r : nil)
        end

        # Average rating for the object as Fixnum
        def rating
          ratings.average(:value, :conditions => 'value > 0')
        end
        
        # Returns rating in American letter grade format (i.e.  A-, B, C+, F, etc.) as String
        def rating_letter
          return self.to_letter_grade(ratings.average('value'))
        end
        
        def to_letter_grade(r)
          return "UR" if r.to_i <= 0
          letter = ['F','D','C','B','A','A'][r.to_i]
          if r.to_i == 5
            letter_mod = '+'
          elsif r.to_i < 1
            letter_mod = ''
          else
            letter_mod = ['-','','+'][((r - r.to_i) * 3).to_i]
          end
          return letter + letter_mod
        end
        
        def can_be_rated_by?(user)
          return (ratings.find_by_user_id(user.id).nil? ? true : false)
        end
        
        def flag!(user=nil)
          rate(0,user)
        end
        
        # Has the object received more than the threshold of ratings with value -1
        def is_flagged?
          if approved
            return false 
          else
            return false if rating.nil?
            threshold_pct = 0.25
            threshold_ratings = 5
            # did the object get more than threshold_ratings ratings, of which more than threshold_pct were flags
            return ((([ratings.count(:conditions => 'value = 0'),1].max / ratings.count ) > threshold_pct) and ratings.count > threshold_ratings)
          end
        end
        
      end
      
    end
  end
end
