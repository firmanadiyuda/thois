require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_text "Events"
  end

  test "should create event" do
    visit events_url
    click_on "New event"

    fill_in "Description", with: @event.description
    fill_in "Name", with: @event.name
    click_on "Create"

    assert_text "Event was successfully created"
  end

  test "should update Event" do
    visit event_url(@event)
    click_on "Edit", match: :first

    fill_in "Description", with: @event.description
    fill_in "Name", with: @event.name
    click_on "Update"

    assert_text "Event was successfully updated"
  end

  test "should destroy Event" do
    visit event_url(@event)
    click_on "Edit", match: :first
    click_on "Delete", match: :first

    assert_text "Event was successfully destroyed"
  end
end
