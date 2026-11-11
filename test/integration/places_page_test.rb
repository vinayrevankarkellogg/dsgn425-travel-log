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

  test "Each place on the places page links to that place's page." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save

    get("/places")

    assert_response(:success)
    assert_select("a[href='/places/#{lisbon["id"]}']", { :text => "Lisbon" })
    assert_select("a[href='/places/#{kyoto["id"]}']", { :text => "Kyoto" })
  end

  test "The place's page displays the name of the place." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    get("/places/#{lisbon["id"]}")

    assert_response(:success)
    assert_select("h1", { :text => "Lisbon" })
  end

  test "The place's page lists each of its entries with its title, description, and the day it happened." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    tram = Entry.new
    tram["title"] = "Tram 28 at sunrise"
    tram["description"] = "Rode the yellow tram from end to end before the crowds."
    tram["occurred_on"] = "2026-03-14"
    tram["place_id"] = lisbon["id"]
    tram.save

    sardines = Entry.new
    sardines["title"] = "Grilled sardines in Alfama"
    sardines["description"] = "Six of them."
    sardines["occurred_on"] = "2026-03-15"
    sardines["place_id"] = lisbon["id"]
    sardines.save

    get("/places/#{lisbon["id"]}")

    assert_response(:success)
    assert_select("li", /Tram 28 at sunrise/)
    assert_select("li", /Rode the yellow tram from end to end before the crowds\./)
    assert_select("li", /2026-03-14/)
    assert_select("li", /Grilled sardines in Alfama/)
    assert_select("li", /Six of them\./)
    assert_select("li", /2026-03-15/)
  end

  test "The place's page only displays entries that belong to that place." do
    lisbon = Place.new
    lisbon["name"] = "Lisbon"
    lisbon.save

    kyoto = Place.new
    kyoto["name"] = "Kyoto"
    kyoto.save

    sardines = Entry.new
    sardines["title"] = "Grilled sardines in Alfama"
    sardines["description"] = "Six of them."
    sardines["occurred_on"] = "2026-03-15"
    sardines["place_id"] = lisbon["id"]
    sardines.save

    shrine = Entry.new
    shrine["title"] = "Fushimi Inari before breakfast"
    shrine["description"] = "Walked the torii gates up the mountain at 6 am."
    shrine["occurred_on"] = "2025-11-02"
    shrine["place_id"] = kyoto["id"]
    shrine.save

    get("/places/#{lisbon["id"]}")

    assert_response(:success)
    assert_select("li", 1)
    assert_select("li", /Grilled sardines in Alfama/)
    assert_select("li", { :text => /Fushimi Inari before breakfast/, :count => 0 })
  end
end
