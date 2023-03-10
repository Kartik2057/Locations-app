import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/helpers/db_helper.dart';
import '../models/place.dart';
import '../helpers/location_helper.dart';


class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  void addPlace (
    String pickedTitle,
    File pickedImage,
    PlaceLocation pickedLocation,
  ) async {
    final address = await LocationHelper.getPlaceAddress(pickedLocation.latitude
    , pickedLocation.longitude);

    final updatedLocation = PlaceLocation(address, pickedLocation.latitude, pickedLocation.longitude);
    
    final newPlace = Place(
      id: DateTime.now().toString(),
      image: pickedImage,
      title: pickedTitle,
      location: updatedLocation,
    );


    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
      'address': newPlace.location.address,
      });
  }

  Place findById(String id){
    return _items.firstWhere(
      (place) => place.id == id
      );
  }


  Future <void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData('user_places');
    _items = dataList.map((item) => Place(
      id: item['id'], 
      title: item['title'], 
      location: PlaceLocation(
        item['address'], 
        item['loc_lat'], 
        item['loc_lng'],
        ), 
      image: File(item['image']),
      )
      ).toList();
      notifyListeners();
  }
}
