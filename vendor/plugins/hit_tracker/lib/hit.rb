class Hit < ActiveRecord::Base
  validates_presence_of :hittable_type, :hittable_id, :kind
end

