require File.dirname(__FILE__) + '/../test_helper'

class HitTrackerTest < Test::Unit::TestCase

  def test_create_hit_succeeds_with_hittable
    old_count = Hit.count
    Hit.create(:hittable_type => '', :hittable_id => '', :kind => 'PageView')
    assert_equal Hit.count, old_count
  end

  def test_create_hit_fails_without_hittable
    old_count = Hit.count
    Hit.create(:hittable_type => '', :hittable_id => '', :kind => 'PageView')
    assert_equal Hit.count, old_count
  end

  def test_has_many_relationship
    t = FakeModel.new
    assert t.respond_to?(:hits)
    assert t.respond_to?(:hit_count)
  end

end

class FakeModel < ActiveRecord::Base

  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  def self.attributes() @attributes ||= {}; end
  def self.attribute(attr, value = 1)
    attributes[attr.to_sym] = value
  end


  column :title, :string
  column :id, :integer
  attribute :id, 1

  track_hits

end
