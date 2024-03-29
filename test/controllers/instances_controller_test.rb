require 'test_helper'

class InstancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @instance = instances(:one)
  end

  test "should get index" do
    get instances_url
    assert_response :success
  end

  test "should get new" do
    get new_instance_url
    assert_response :success
  end

  test "should create instance" do
    assert_difference('Instance.count') do
      post instances_url, params: { instance: { end_date: @instance.end_date, local: @instance.local, name: @instance.name, order: @instance.order, project_id: @instance.project_id, protocol_id: @instance.protocol_id, score: @instance.score, start_date: @instance.start_date, user_id: @instance.user_id } }
    end

    assert_redirected_to instance_url(Instance.last)
  end

  test "should show instance" do
    get instance_url(@instance)
    assert_response :success
  end

  test "should get edit" do
    get edit_instance_url(@instance)
    assert_response :success
  end

  test "should update instance" do
    patch instance_url(@instance), params: { instance: { end_date: @instance.end_date, local: @instance.local, name: @instance.name, order: @instance.order, project_id: @instance.project_id, protocol_id: @instance.protocol_id, score: @instance.score, start_date: @instance.start_date, user_id: @instance.user_id } }
    assert_redirected_to instance_url(@instance)
  end

  test "should destroy instance" do
    assert_difference('Instance.count', -1) do
      delete instance_url(@instance)
    end

    assert_redirected_to instances_url
  end
end
