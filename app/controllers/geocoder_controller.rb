class GeocoderController < ApplicationController
  
  def geocode_st
  end

  def geocode_stt
  end

  def geocoder2
  end
  
=begin
http://localhost:3000/geocoder/search?q=paris&limit=5&format=json&addressdetails=1&json_callback=_l_geocoder_0

_l_geocoder_3([
{"place_id":"177325538","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright","osm_type":"relation","osm_id":"7444","boundingbox":["48.8155755","48.902156","2.224122","2.4697602"],"lat":"48.8566101","lon":"2.3514992","display_name":"Paris, Île-de-France, France métropolitaine, France","class":"place","type":"city","importance":0.31723364983048,"icon":"http:\/\/nominatim.openstreetmap.org\/images\/mapicons\/poi_place_city.p.20.png","address":{"city":"Paris","county":"Paris","state":"Île-de-France","country":"France","country_code":"fr"}},
{"place_id":"177743902","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright","osm_type":"relation","osm_id":"71525","boundingbox":["48.8155755","48.902156","2.224122","2.4697602"],"lat":"48.85881005","lon":"2.32003101155031","display_name":"Paris, Île-de-France, France métropolitaine, France","class":"boundary","type":"administrative","importance":0.31723364983048,"icon":"http:\/\/nominatim.openstreetmap.org\/images\/mapicons\/poi_boundary_administrative.p.20.png","address":{"county":"Paris","state":"Île-de-France","country":"France","country_code":"fr"}},
{"place_id":"179897573","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright","osm_type":"relation","osm_id":"6678712","boundingbox":["35.26725","35.3065029","-93.761807","-93.675083"],"lat":"35.2920325","lon":"-93.7299173","display_name":"Paris, Logan County, Arkansas, 72855, États-Unis d'Amérique","class":"place","type":"city","importance":0.24346471215672,"icon":"http:\/\/nominatim.openstreetmap.org\/images\/mapicons\/poi_place_city.p.20.png","address":{"city":"Paris","county":"Logan County","state":"Arkansas","postcode":"72855","country":"États-Unis d'Amérique","country_code":"us"}},
{"place_id":"179191907","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright","osm_type":"relation","osm_id":"115357","boundingbox":["33.611853","33.738378","-95.627928","-95.435455"],"lat":"33.6617962","lon":"-95.555513","display_name":"Paris, Lamar County, Texas, 75460, États-Unis d'Amérique","class":"place","type":"city","importance":0.21093610937791,"icon":"http:\/\/nominatim.openstreetmap.org\/images\/mapicons\/poi_place_city.p.20.png","address":{"city":"Paris","county":"Lamar County","state":"Texas","postcode":"75460","country":"États-Unis d'Amérique","country_code":"us"}},
{"place_id":"179299377","licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright","osm_type":"relation","osm_id":"130722","boundingbox":["38.164922","38.238271","-84.307326","-84.232089"],"lat":"38.2097987","lon":"-84.2529869","display_name":"Paris, Bourbon County, Kentucky, 40361, États-Unis d'Amérique","class":"place","type":"city","importance":0.20270658026042,"icon":"http:\/\/nominatim.openstreetmap.org\/images\/mapicons\/poi_place_city.p.20.png","address":{"city":"Paris","county":"Bourbon County","state":"Kentucky","postcode":"40361","country":"États-Unis d'Amérique","country_code":"us"}}
])
Content-Type: application/javascript; charset=UTF-8
=end
  
  def search
    json_callback = params[:json_callback]
    q = params[:q]
    limit = params[:limit]
    vect = Kbase::StationTrack.geosearch(q,limit)
    str = vect.to_json
    render json: "#{json_callback}(#{str})", status: :ok, content_type: "application/javascript; charset=UTF-8"    
  end

  def search_station
    json_callback = params[:json_callback]
    q = params[:q]
    limit = params[:limit]
    vect = Kbase::Station.geosearch(q,limit)
    str = vect.to_json
    render json: "#{json_callback}(#{str})", status: :ok, content_type: "application/javascript; charset=UTF-8"    
  end
  
  def reverse
    lat = params[:lat]
    lon = params[:lon]
    json_callback = params[:json_callback]
    object = Kbase::Station.find_by_lat_lon(lat,lon)
    str = object[0].to_json
    render json: "#{json_callback}(#{str})", status: :ok, content_type: "application/javascript; charset=UTF-8"
  end

  def geocoder
    
  end
  
end

=begin

Content-Type: application/vnd.geo+json; charset=utf-8

http://localhost:3000/geocoder/reverse?lat=47566.50193612848&lon=-32416.77885966003&zoom=-7&addressdetails=1&format=json&json_callback=_l_geocoder_1

https://nominatim.openstreetmap.org/reverse?lat=38.88849416908772&lon=-77.0577621459961&zoom=18&addressdetails=1&format=json&json_callback=_l_geocoder_1

_l_geocoder_1({"place_id":"216921829",
"licence":"Data © OpenStreetMap contributors, ODbL 1.0. http:\/\/www.openstreetmap.org\/copyright",
"osm_type":"way","osm_id":"50579250",
"lat":"38.8862026",
"lon":"-77.0589277",
"display_name":"Arlington Memorial Bridge, Washington, District of Columbia, 20006, États-Unis d'Amérique",
"address":{"path":"Arlington Memorial Bridge","city":"Washington","state":"District of Columbia",
           "postcode":"20006",
            "country":"États-Unis d'Amérique","country_code":"us"},
"boundingbox":["38.8862026","38.8886823","-77.0589277","-77.052134"]})

=end
