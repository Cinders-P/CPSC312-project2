%%% main.pl defines the search predicate that should be used to send queries

%%% User-Defined Modules
:- ensure_loaded([client, writer]). % try_search/4, print_results/1

%%% PROGRAM ENTRYPOINT
search(Location) :- search("Restaurants", Location).
search(Term, Location) :- search(Term, Location, [1,2,3,4], 0).
search(Term, Location, PriceList, MinRating) :-
  atom_string(Term, TermStr),
  atom_string(Location, LocStr),
  numbers_to_string(PriceList, PriceStr),
  try_search(TermStr, LocStr, PriceStr, Json),
  get_list(Json,MinRating, _).

%%% Yelp Price Scale: 1=$, 2=$$, 3=$$$, 4=$$$$
is_valid_price(Num) :- Num >= 1, Num =< 4.

%%% Convert list input into comma separated string
numbers_to_string([], "").
numbers_to_string([H], PriceString) :- is_valid_price(H), number_string(H, PriceString).

% only matches lists with at least two elements, so that the
% last element doesn't have a trailing comma
numbers_to_string([H1,H2|T], PriceString) :-
  is_valid_price(H1),
  numbers_to_string([H2|T], TString), 
  number_string(H1, HString),
  string_concat(HString, ",", HComma),
  string_concat(HComma, TString, PriceString).

% If given an atom or string (e.g. 3 or "1,2"), just return it.
% No input validation is done in this case.
numbers_to_string(Input, Str) :- \+ is_list(Input), atom_string(Input, Str).
