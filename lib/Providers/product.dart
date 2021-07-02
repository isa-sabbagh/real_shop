import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class Product with ChangeNotifier {
  final String id;
  final String title;
  final String desc;
  final double price;
  final String imgUrl;
  bool isFav;

  Product(
      {@required this.id,
      @required this.title,
      @required this.desc,
      @required this.price,
      @required this.imgUrl,
      this.isFav = false});

  void _setFavValue(bool newValue) {
    isFav = newValue;
    notifyListeners();
  }

  Future<void> toggleFavState(String token, String userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();

    final url =
        'https://shop-f721b-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final res = await http.put(url, body: json.encode(isFav));
      if (res.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (e) {
      _setFavValue(oldStatus);
    }
  }
}
