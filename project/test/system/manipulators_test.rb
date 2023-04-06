require "application_system_test_case"

class ManipulatorsTest < ApplicationSystemTestCase
  setup do
    @manipulator = manipulators(:one)
  end

  test "visiting the index" do
    visit manipulators_url
    assert_selector "h1", text: "Manipulators"
  end

  test "should create manipulator" do
    visit manipulators_url
    click_on "New manipulator"

    fill_in "名称", with: @manipulator.名称
    fill_in "密码", with: @manipulator.密码
    fill_in "类型", with: @manipulator.类型
    click_on "Create Manipulator"

    assert_text "Manipulator was successfully created"
    click_on "Back"
  end

  test "should update Manipulator" do
    visit manipulator_url(@manipulator)
    click_on "Edit this manipulator", match: :first

    fill_in "名称", with: @manipulator.名称
    fill_in "密码", with: @manipulator.密码
    fill_in "类型", with: @manipulator.类型
    click_on "Update Manipulator"

    assert_text "Manipulator was successfully updated"
    click_on "Back"
  end

  test "should destroy Manipulator" do
    visit manipulator_url(@manipulator)
    click_on "Destroy this manipulator", match: :first

    assert_text "Manipulator was successfully destroyed"
  end
end
