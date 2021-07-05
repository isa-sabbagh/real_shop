import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Models/http_exception.dart';
import '../Providers/product.dart';

import 'package:flutter/material.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      desc: 'A red shirt - it is pretty red!',
      price: 29.99,
      imgUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      desc: 'A nice pair of trousers.',
      price: 59.99,
      imgUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      desc: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imgUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      desc: 'Prepare any meal you want.',
      price: 49.99,
      imgUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    Product(
      id: 'p5',
      title: 'A Pan',
      desc: 'Prepare any meal you want.',
      price: 29.99,
      imgUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];
  String authToken;
  String userId;

  gtData(String authTok, String uId, List<Product> products) {
    authToken = authTok;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items => [..._items];

  List<Product> get favorites => _items.where((el) => el.isFav).toList();

  Product finddById(String id) =>
      _items.firstWhere((product) => product.id == id);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    print('fetchAndSetProducts->userId :$userId');
    final filteredString =
        filterByUser ? 'orderBy="creatorId"&equalto="$userId"' : '';
    var url =
        'https://shop-f721b-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString';

    try {
      final res = await http.get(url);

      final extractedData = json.decode(res.body) as Map<String, dynamic>;

      if (extractedData == null) return;

      url =
          'https://shop-f721b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favRes = await http.get(url);
      final favData = json.decode(favRes.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          desc: prodData['desc'],
          price: prodData['price'],
          imgUrl: prodData['imgUrl'],
          isFav: favData == null ? false : favData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-f721b-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final res = await http.post(url,
          body: json.encode({
            'title': product.title,
            'desc': product.desc,
            'imgUrl': product.imgUrl,
            'isFav': product.isFav,
            'price': product.price,
            'creatorId': userId,
          }));

      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          desc: product.desc,
          imgUrl: product.imgUrl,
          isFav: product.isFav,
          price: product.price);

      _items.add(newProduct);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newproduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      final url =
          'https://shop-f721b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newproduct.title,
            'desc': newproduct.desc,
            'imgUrl': newproduct.imgUrl,
            'isFav': newproduct.isFav,
            'price': newproduct.price,
          }));
      _items[prodIndex] = newproduct;
      notifyListeners();
    } else
      print('...');
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-f721b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);

    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);

    notifyListeners();

    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Not deleted!!');
    }
    existingProduct = null;
  }
}
