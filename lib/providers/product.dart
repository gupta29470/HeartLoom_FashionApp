import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String authToken, String userId) async {
    // favorite to un-favorite a un-favorite to favorite
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://yooutlet-d3b8e.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      await http.put(url,
          body: json.encode(
            isFavorite,
          ));
    } catch (error) {
      isFavorite= oldStatus;
    }
  }
}
