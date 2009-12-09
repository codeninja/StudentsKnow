module Resource
  module Tracker
    def self.included(base)
      base.extend(ClassMethods)
      Hit.send(:belongs_to, base.class.name.to_sym, :polymorphic => true)
    end

    module ClassMethods
      def track_hits
        has_many :hits, :as => :hittable, :dependent => :destroy
        include Resource::Tracker::SingletonMethods
      end
    end

    module SingletonMethods
      def hit_count
        return self.hits.size
      end

      def hit(kind = 'PageView', user_id = 0)
        self.hits.create(:kind => kind, :user_id => user_id)
      end

      def hit!(kind = 'PageView')
        self.hits.create!(:kind => kind, :user_id => user_id)
      end
    end
  end
end
