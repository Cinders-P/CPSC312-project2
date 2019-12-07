%%% writer.pl parses Dicts and pretty-prints results to the `stdout` stream

:- use_module(library(lists)).

% write_list(List) is true if List is a list of anything
write_list([]).
write_list([H|T]):-
        write(H),nl,
        write_list(T).

% filter_list(Elems, List, Filtered) is true if FilteredList is a filtered list from List

filter_list([], L, L).
filter_list([H|T], List, Filtered) :-
       delete_kv_pair(H, List, FilteredList),
       filter_list(T, FilteredList, Filtered).

% get_list(RestList,Json) is true if RestList is a json object corresponding to 
% list of businesses in the json object
get_list(json([]),_,[]).
get_list(json([H|_]),MinRating, Value) :-
        key_value_pair(businesses, Value, [H]),
        get_restaurant_list(Value,MinRating,_).

% get_restaurant_list(Restaurants,Json) is true if Restaurants is a 
% list of restaurant objects corresponding to Json, a list of json objects
get_restaurant_list([],_,[]).
get_restaurant_list([ResH|ResT],MinRating,[JsonH|JsonT]) :-
	convert_to_restaurant(ResH,MinRating,JsonH),
	get_restaurant_list(ResT,MinRating,JsonT).

% delete_kv_pair(k, lst, res) returns true if k is deleted from lst
delete_kv_pair(_,[],[]).
delete_kv_pair(Key,[H],[H]) :- not(key_value_pair(Key,_,[H])).
delete_kv_pair(Key,[H],[]) :- key_value_pair(Key,_,[H]).
delete_kv_pair(Key,[H|T],[H|Recursion]) :- 
		not(key_value_pair(Key,_,[H])),
		delete_kv_pair(Key,T,Recursion).
delete_kv_pair(Key,[H|T],T) :- key_value_pair(Key,_,[H]).

% key_value_pair(k, v, lst) returns true if lst contains an entry k=v 
key_value_pair(Key,Value,[(Key=Value)|_]).
key_value_pair(Key,Value,[_|T]) :- key_value_pair(Key, Value, T).

% contains_key(k,lst) returns true if lst contains an entry k=v for some v
contains_key(K,Lst) :- key_value_pair(K,_,Lst).

% add_details(Restaurant,UndetailedRestaurant,Json) is true if Restaurant is 
% the UndetailedRestaurant with extra information from Json added 
add_details(restaurant(Basic_info, Review_info, Location_info, contact_details(Phone, Hours, Open_now)), 
	restaurant(Basic_info, Review_info, Location_info, contact_details(Phone, _, _)), List) :-
		key_value_pair(hours, [json(RawHours)], List),
		get_hour_info(Hours, Open_now, RawHours).

% get_hour_info(Hours, OpenNow, RawHours) is true if Hours is the list of
% open hours corresponding to RawHours json, and OpenNow is the value of
% the is_open_now json key in RawHours json.
get_hour_info(Hours, OpenNow, RawHours) :-
	key_value_pair(open, HourList, RawHours),
	get_hours(Hours, HourList),
	key_value_pair(is_open_now, OpenNow, RawHours).

% Parse the opening hours returned in JSON to a list of hour(Day,Start,End)
% get_hours(ParsedHours, RawJsonHours) is true if ParsedHours is the corresponding
% list of hour(Day,Start,End) data to the json representation in RawJsonHours
get_hours([],[]).
get_hours([hour(Day,Start,End)|HoursRest], [json(JsonObj)|JsonRest]) :-
	key_value_pair(day,Day,JsonObj),
	key_value_pair(start,Start,JsonObj),
	key_value_pair(end,End,JsonObj),
	get_hours(HoursRest, JsonRest).

% convert_to_restaurant(Restaurant, Json) is true if R is the restaurant object 
% parsed from Json
convert_to_restaurant(json(List),Minrating,restaurant(Basic_info, Review_info,
   Location_info, contact_details(Phone,'',''))) :-
	convert_to_basic_info(Basic_info, List),
	convert_to_review_info(Review_info, List),
	convert_to_location_info(Location_info, List),
	get_nullable_property(phone, Phone, List),
	filter_list([id,alias,image_url,url,coordinates,transactions,phone], List, Filt),
	filter_res(Filt,Final),
	checkrating(Minrating,Final).

checkrating(Minrating,List) :-
	findkeyrating(Minrating,List,[],true,Res),
	write_list(Res), nl.
checkrating(Minrating,List) :-
	findkeyrating(Minrating,List,[],false,_).

findkeyrating(_,[],List,_,List).
findkeyrating(Minrating,[H|T],List,Bool,Flist) :-
	comparerating(Minrating,H,Bool,Res),
	findkeyrating(Minrating,T,[Res|List],Bool,Flist).

comparerating(_,(Key=V),_,(Key=V)) :-
	dif(Key,rating).
comparerating(Minrating,(Key=V),Bool,(Key=R)) :- 
	Key = rating,
	compareval(Minrating,V,R,Bool).

compareval(Minrating,V,V,false) :-
	Minrating > V.
compareval(Minrating,V,V,true) :-
	Minrating =< V.

filter_res(Lst,Filt) :-
	reverse(Lst,List),
	location_format(List,[],L1),
	categories_format(L1,[],Filt).

categories_format([],List,List).
categories_format([H|T],List,Flist) :-
	formatcat(H,Res),
	categories_format(T,[Res|List],Flist).

formatcat((Key=V),(Key=V)) :-
	dif(Key,categories).
formatcat((Key=V),(Key=R)) :- 
	Key = categories,
	cat_form(V,[],R).

cat_form([],List,List).
cat_form([H|T],List,Flist) :-
	removejson(H,H1),
	cat_form(T,[H1|List],Flist).

removejson(json(List),V) :-
	last(List,K),
	display(K,V).

location_format([],List,List).
location_format([H|T],List,Flist) :-
	formatloc(H,Res),
	location_format(T,[Res|List],Flist).

formatloc((Key=V),(Key=V)) :-
	dif(Key,location).
formatloc((Key=V),(Key=R)) :- 
	Key = location,
	loc_form(V, R).

loc_form(json(List),Res) :-
	last(List,R),
	display(R,Res).

display(_=Value,Value).

coor_format([],List,List).
coor_format([H|T],List,Flist) :-
	formatcoor(H,Res),
	coor_format(T,[Res|List],Flist).

formatcoor((Key=V),(Key=V)) :-
	dif(Key,coordinates).
formatcoor((Key=V),(Key=R)) :- 
	Key = coordinates,
	coor_form(V, R).

coor_form(json(List),List).

% convert_to_restaurant(Info, List) is true if Info is the basic_info object 
% extracted from List
convert_to_basic_info(basic_info(Id, Name, Price, Categories), List) :-
	key_value_pair(id, Id, List),
	get_nullable_property(name, Name, List),
	get_nullable_property(price, Price, List), % $$$
	key_value_pair(categories, CategoriesList, List),
	get_category_list(Categories, CategoriesList).

% convert_to_restaurant(Review, List) is true if Review is the review object 
% extracted from List
convert_to_review_info(review_info(Review_Count, Rating), List) :-
	get_nullable_property(review_count, Review_Count, List),
	get_nullable_property(rating, Rating, List).

% convert_to_restaurant(LocationInfo, List) is true if LocationInfo is the location_info 
% object extracted from Json
convert_to_location_info(location_info(Address, Coordinates, Distance), List) :-
	key_value_pair(coordinates, CoordinatesList, List),
	get_coordinates(CoordinatesList, Coordinates),
	key_value_pair(location, LocationJson, List),
	convert_to_address(Address, LocationJson),	
	get_nullable_property(distance, Distance, List).

% get_nullable_property returns true if the list contains the value for the 
% property or if the property isn't present and the value is not available
get_nullable_property(Property,Value,List) :- key_value_pair(Property, Value, List).
get_nullable_property(Property,'not available', List) :- \+contains_key(Property, List).

% get_category_list(Categories,Json) is true if Categories is the categories object 
% parsed from Json
get_category_list([],[]).
get_category_list([H|T], [json(Json)|JsonTail]) :- 
        key_value_pair(alias, H, Json),
        get_category_list(T, JsonTail).

% get_coordinates(Coordinates,Json) is true if Coordinates is the coordinates 
% object parsed from Json
get_coordinates(json(List), (Lat,Lon)) :- 
        key_value_pair(latitude, Lat, List), 
        key_value_pair(longitude, Lon, List).

% getLocation(Location,Json) is true if Location is the location object parsed from Json
convert_to_address(address(Add1, Add2, Add3, City, Zip, Country, State), json(LocationJson)) :-
	key_value_pair(address1, Add1, LocationJson),
	key_value_pair(address2, Add2, LocationJson),
	key_value_pair(address3, Add3, LocationJson),
	key_value_pair(city, City, LocationJson),
	key_value_pair(zip_code, Zip, LocationJson),
	key_value_pair(country, Country, LocationJson),
	key_value_pair(state, State, LocationJson).

% get_property_list(Restaurants,Property,Properties) is true 
% if Properties is a list of Property for each restaurant in Restaurants
get_property_list([],_,[]).
get_property_list([H|T],Prop,[H2|T2]) :- 
        get_property(H, Prop, H2),
        get_property_list(T, Prop, T2).

% get_property(Restaurant,Property,Value) is true if property Property has 
% value Value in the given Restaurant
get_property(restaurant(basic_info(Id,_,_,_),_,_,_), id, Id).
get_property(restaurant(basic_info(_,Name,_,_),_,_,_), name, Name).
get_property(restaurant(basic_info(_,_,Price,_),_,_,_), price, Price).
get_property(restaurant(basic_info(_,_,_,Categories),_,_,_), caregories, Categories).
get_property(restaurant(_,review_info(Review_count,_),_,_),reviews, Review_count).
get_property(restaurant(_,review_info(_,Rating),_,_),rating, Rating).

% address(add1, add2, add3, city, zip, country, state)
get_property(restaurant(_,_,location_info(address(Add1, _, _, _, _, _, _),_,_),_),address, Add1).
get_property(restaurant(_,_,location_info(address(_, _, _, _, _, _, State),_,_),_),state, State).
get_property(restaurant(_,_,location_info(address(_, _, _, _, _, Country, _),_,_),_),country, Country).
get_property(restaurant(_,_,location_info(address(_, _, _, _, Zip, _, _),_,_),_),zip, Zip).
get_property(restaurant(_,_,location_info(address(_, _, _, City, _, _, _),_,_),_),city, City).
get_property(restaurant(_,_,location_info(_,Coordinates,_),_),coordinates, Coordinates).
get_property(restaurant(_,_,_,contact_details(Phone,_,_)), phone, Phone).
get_property(restaurant(_,_,_,contact_details(_,Hours,_)), hours, Hours).
