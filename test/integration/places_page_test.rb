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
end
