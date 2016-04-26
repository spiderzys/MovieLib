#MovieLib
(data from API provided by https://www.themoviedb.org/documentation/api (JSON style)
This app is to provide movie infomation for users. key word: core data, plist, network session, API, multithread, size class, auto layout....

1st module
Content: show the information current playing movie in theatre (title, rate, cast, overview, review, poster and trailor if applicable)
Feature: multithread image loading, Using "core data" technique to save data downloaded from API for offline use next time. Can play movie's tralior with classes supported by Youtube. Support data refeashing by swipe.

2st tab:
Content: Search movie by keyword and list results. 
Feature: results can be sorted or re-sorted by their date or rate. Tap a result shows corresponding movie.  

3st tab: login system (network session, use plist to save user's session ID), login the account of API provider, and show users rated movies
Feature: rate movie (not finished), divide rated movies into different classes based on users' rating. Recommend users movie according their rating (not finished), tapping a result shows its detail.
