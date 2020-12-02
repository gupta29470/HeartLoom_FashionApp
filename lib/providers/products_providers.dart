import 'dart:convert';

import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // product list
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ]; //private variable _items

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this._items, this.userId);

  List<Product> get items {
    // getter method
    return [..._items]; // returning copy of list not an actual list
  }

  Product findById(String id) {
    // function to return product as dedicated id
    return _items.firstWhere((prod) => prod.id == id);
  }

  // function to return favorite value
  List<Product> get onlyFavoritesItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // ignore: missing_return
  // Method 1: To add product and handling errors
  Future<void> addProducts(Product product) {
    const url = 'https://yooutlet-d3b8e.firebaseio.com/products.json';
    // we have to store data in json, but we can't pass product directly
    // because it is not possible to convert dart object to json,
    // but it is possible to convert map to json

    // Dart treat as done as soon as it send request
    return http
        .post(
      url,
      body: json.encode({
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }),
    )
        // then is used to wait if above get executed then only it runs following
        // code
        .then((response) {
      final newProduct = new Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'], // firebase product id
      );
      _items.add(newProduct);
      notifyListeners();
    }).catchError((error) {
      // passing error
      print(error);
      throw (error);
    });

    //Dart immediately executes this without waiting response for
    // http request
    final newProduct = new Product(
      title: product.title,
      price: product.price,
      description: product.description,
      imageUrl: product.imageUrl,
      id: DateTime.now().toString(),
    );
  }

  // Method 2: To add product and handling errors
  Future<void> addProduct(Product product) async {
    final url =
        'https://yooutlet-d3b8e.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'title': product.title,
              'price': product.price,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'creatorId': userId,
              //'isFavorite': product.isFavorite,
            },
          ));
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url =
          'https://yooutlet-d3b8e.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            //'isFavorite': newProduct.isFavorite,
          },
        ),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProducts(String id) {
    final url =
        'https://yooutlet-d3b8e.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    // if delete succeed it will delete
    http.delete(url).then((_) {
      existingProduct = null;
    })
        // otherwise insert again in list
        .catchError((error) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://yooutlet-d3b8e.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      // it returns nested maps
      // gives dynamic because dart does not understand nested maps
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://yooutlet-d3b8e.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          new Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
