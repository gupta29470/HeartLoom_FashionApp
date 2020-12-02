import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get getOrders {
    return [..._orders];
  }

  Future<void> addOrders(List<CartItem> cartProducts, double total) async {
    final url = 'https://yooutlet-d3b8e.firebaseio.com/orders/$userId.json?auth=$authToken';
    // store date and time exactly when user orders, because after this we have
    // trigger http request which can delay order time and not giving
    // exact time
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          // uniform string representation of dates
          // we can't send dateTime object
          // we can't convert to normal string because we have to convert this
          // special type of string in to dateTime in dart. Easy to convert
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cartProd) => {
                    'id': cartProd.id,
                    'title': cartProd.title,
                    'quantity': cartProd.quantity,
                    'price': cartProd.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0, // index
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            cartItems: cartProducts,
            dateTime: DateTime.now()));
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://yooutlet-d3b8e.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            cartItems: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    price: item['price'],
                    quantity: item['quantity'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(
              orderData['dateTime'],
            ),
          ),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.cartItems,
      @required this.dateTime});
}
