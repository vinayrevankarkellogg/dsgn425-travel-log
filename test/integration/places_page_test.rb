require "test_helper"

class PlacesPageTest < ActionDispatch::IntegrationTest
  test "The places page shows a list of all the places." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save

    get("/places")

    assert_response(:success)
    assert_select("li", 2)
  end

  test "Each place in the list displays its name." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save

    get("/places")

    assert_response(:success)
    assert_select("li", { :text => "Lisbon" })
    assert_select("li", { :text => "Kyoto" })
  end

  test "The home page has a working link to the places page." do
    get("/")

    assert_response(:success)
    assert_select("a[href='/places']")

    get("/places")

    assert_response(:success)
  end

  test "The places page has a link to add a new place." do
    get("/places")

    assert_response(:success)
    assert_select("a[href='/places/new']")
  end

  test "The new place page has a form with an input for the place name." do
    get("/places/new")

    assert_response(:success)
    assert_select("form[action='/places'][method='post']") do
      assert_select("input[name='name']")
      assert_select("button")
    end
  end

  test "Submitting the form creates a new place with the entered name." do
    post("/places", :params => { "name" => "Mexico City" })

    place = Place.find_by({ "name" => "Mexico City" })
    assert_not_nil(place)
  end

  test "After submitting, the user lands on the places page and sees the new place there." do
    post("/places", :params => { "name" => "Mexico City" })

    assert_redirected_to("/places")
    follow_redirect!

    assert_response(:success)
    assert_select("li", { :text => "Mexico City" })
  end
end
