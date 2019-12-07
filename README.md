### Authors
|Name             |Student #  |csid|
|-----------------|-----------|-----|
|Cindy Hsu        |16812166   |q3a1b|
|Theodorus Jossoey|37452802   |v9y1b|

Note: This project requires a yelp api key inside secrets.pl in order to be run.

# Prolog-Yelp Search
_We have seen Prolog to be effective in operating on lists and atoms, but how practical
are the applications?_

This __Prolog__ program formats and sends _HTTP GET_ requests to the Yelp search API.
It is part of an investigation to evaluate the effectiveness of logic programming on
complex objects, as well as test out various _I/O_ and _JSON_ marshalling built-ins that
Prolog offers.

Upon querying with `search/1;2;4`, the program will print up to __10 restaurants__ that
best match the query.

`4xx` and `5xx` response statuses are printed to stderr.

## Instructions
1. `swipl`
2. `[main]`
3. `search("<search-terms>", "<location (REQUIRED)>", <price-list>, <min-rating>).`

The convenience methods `search("<location>").` and `search("search-terms>", "<location>").` also work if you want to include all prices and ratings. Only __location__ is required. No quotes are required if the search term/location are one word, as the atom will automatically be converted into a string. For example: `search("cat cafe", vancouver).` Minimum Rating should be a single number from 0-5.

### Price List
Price list is a filter, in case you want to exclude cheap or expensive restaurants.

`<price-list>` should be in the format `[1,2,3,4]`, with the greater numbers representing more expensive restaurants.
Only 1-4 are legal, and any other numbers will cause the program to return `false`. The list should contain the prices you want to include in your search.

E.g. "I want cheap restaurants! $ and $$ only!" -> `[1,2]`

---

## Creating Prolog Executables
With __swi-prolog__ installed:

`swipl -o mystate --stand_alone=true -c main.pl`

This .exe should be executable on any machine of the same architecture.

---

# Demo Examples

