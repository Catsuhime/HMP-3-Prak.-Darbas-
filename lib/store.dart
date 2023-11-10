// store.dart
import 'package:redux/redux.dart';
import 'reducers.dart';
import 'dart:convert';
import 'actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String kListingsKey = 'listings';

Future<List<Listing>> loadListings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? listingsJson = prefs.getString(kListingsKey);
  if (listingsJson != null) {
    List<dynamic> decodedListings = json.decode(listingsJson);
    return decodedListings.map((item) => Listing.fromJson(item)).toList();
  }
  return [];
}

Future<void> saveListings(List<Listing> listings) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String listingsJson = json.encode(listings);
  await prefs.setString(kListingsKey, listingsJson);
}

final Store<List<Listing>> store = Store<List<Listing>>(
  rootReducer,
  initialState: [],
);





