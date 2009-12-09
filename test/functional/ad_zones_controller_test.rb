require File.dirname(__FILE__) + '/../test_helper'

class AdZonesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ad_zones)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_ad_zone
    assert_difference('AdZone.count') do
      post :create, :ad_zone => { }
    end

    assert_redirected_to ad_zone_path(assigns(:ad_zone))
  end

  def test_should_show_ad_zone
    get :show, :id => ad_zones(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => ad_zones(:one).id
    assert_response :success
  end

  def test_should_update_ad_zone
    put :update, :id => ad_zones(:one).id, :ad_zone => { }
    assert_redirected_to ad_zone_path(assigns(:ad_zone))
  end

  def test_should_destroy_ad_zone
    assert_difference('AdZone.count', -1) do
      delete :destroy, :id => ad_zones(:one).id
    end

    assert_redirected_to ad_zones_path
  end
end
