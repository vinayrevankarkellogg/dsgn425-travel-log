require "test_helper"

class EntriesPageTest < ActionDispatch::IntegrationTest
  test "The place's page has a link to add a new entry for that place." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/places/#{place["id"]}")

    assert_response(:success)
    assert_select("a[href='/entries/new?place_id=#{place["id"]}']")
  end

  test "The new entry page has a form with inputs for title, description, and date." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    get("/entries/new?place_id=#{place["id"]}")

    assert_response(:success)
    assert_select("form[action='/entries'][method='post']") do
      assert_select("input[name='place_id'][value='#{place["id"]}']")
      assert_select("input[name='title']")
      assert_select("input[name='description']")
      assert_select("input[name='occurred_on']")
      assert_select("button")
    end
  end

  test "Submitting the form creates an entry for that place with the title, description, and date that were entered." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    post("/entries", :params => { "title" => "Grilled sardines in Alfama", "description" => "Six of them.", "occurred_on" => "2026-03-15", "place_id" => place["id"] })

    entry = Entry.find_by({ "title" => "Grilled sardines in Alfama" })
    assert_not_nil(entry)
    assert_equal("Six of them.", entry["description"])
    assert_equal(Date.parse("2026-03-15"), entry["occurred_on"])
    assert_equal(place["id"], entry["place_id"])
  end

  test "After submitting, the user lands on the place's page and sees the new entry there." do
    place = Place.new
    place["name"] = "Lisbon"
    place.save

    post("/entries", :params => { "title" => "Grilled sardines in Alfama", "description" => "Six of them.", "occurred_on" => "2026-03-15", "place_id" => place["id"] })

    assert_redirected_to("/places/#{place["id"]}")
    follow_redirect!
    assert_select("li", /Grilled sardines in Alfama/)
  end
end
