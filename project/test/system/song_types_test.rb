require "application_system_test_case"

class SongTypesTest < ApplicationSystemTestCase
  setup do
    @song_type = song_types(:one)
  end

  test "visiting the index" do
    visit song_types_url
    assert_selector "h1", text: "Song types"
  end

  test "should create song type" do
    visit song_types_url
    click_on "New song type"

    fill_in "名称", with: @song_type.名称
    click_on "Create Song type"

    assert_text "Song type was successfully created"
    click_on "Back"
  end

  test "should update Song type" do
    visit song_type_url(@song_type)
    click_on "Edit this song type", match: :first

    fill_in "名称", with: @song_type.名称
    click_on "Update Song type"

    assert_text "Song type was successfully updated"
    click_on "Back"
  end

  test "should destroy Song type" do
    visit song_type_url(@song_type)
    click_on "Destroy this song type", match: :first

    assert_text "Song type was successfully destroyed"
  end
end
