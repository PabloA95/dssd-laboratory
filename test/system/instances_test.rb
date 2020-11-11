require "application_system_test_case"

class InstancesTest < ApplicationSystemTestCase
  setup do
    @instance = instances(:one)
  end

  test "visiting the index" do
    visit instances_url
    assert_selector "h1", text: "Instances"
  end

  test "creating a Instance" do
    visit instances_url
    click_on "New Instance"

    fill_in "End date", with: @instance.end_date
    check "Local" if @instance.local
    fill_in "Name", with: @instance.name
    fill_in "Order", with: @instance.order
    fill_in "Project", with: @instance.project_id
    fill_in "Protocol", with: @instance.protocol_id
    fill_in "Score", with: @instance.score
    fill_in "Start date", with: @instance.start_date
    fill_in "User", with: @instance.user_id
    click_on "Create Instance"

    assert_text "Instance was successfully created"
    click_on "Back"
  end

  test "updating a Instance" do
    visit instances_url
    click_on "Edit", match: :first

    fill_in "End date", with: @instance.end_date
    check "Local" if @instance.local
    fill_in "Name", with: @instance.name
    fill_in "Order", with: @instance.order
    fill_in "Project", with: @instance.project_id
    fill_in "Protocol", with: @instance.protocol_id
    fill_in "Score", with: @instance.score
    fill_in "Start date", with: @instance.start_date
    fill_in "User", with: @instance.user_id
    click_on "Update Instance"

    assert_text "Instance was successfully updated"
    click_on "Back"
  end

  test "destroying a Instance" do
    visit instances_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Instance was successfully destroyed"
  end
end
