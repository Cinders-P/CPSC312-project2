%%% client.pl defines programs for retrieving json data from Yelp,
%%% and outputting the json response as a Dict on success

%%% Standard Library Modules
:- use_module(library(http/http_client)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).

%%% User-Defined Modules
:- ensure_loaded([secrets]). % yelp_api_key/1

%%% Error Handling
try_search(Term, Location, PriceList, Dict) :-
  catch(
    get_search_results(Term, Location, PriceList, Dict),
    Error,
    print_message(error, Error)
  ).

%%% HTTP GET /v3/businesses/search
get_search_results(Term, Location, PriceList, Json) :- 
  yelp_api_key(KEY),
  http_get([
    host('api.yelp.com'),
    path('/v3/businesses/search'),
    search([
      term=Term,
      location=Location,
      price=PriceList,
      limit='20'
    ])
  ], Json, [
    authorization(bearer(KEY))
  ]).
