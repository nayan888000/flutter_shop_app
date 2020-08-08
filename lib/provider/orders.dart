import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import './cart.dart';
import 'dart:convert';

class Orderitem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Orderitem({
    @required this.id,
    @required this.amount,
    @required this.date,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<Orderitem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this._orders,this.userId);

  List<Orderitem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://shopapp-77921.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quant,
                    'price': e.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      Orderitem(
        id: json.decode(response.body)['name'],
        amount: total,
        date: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndOrders() async {
    final url = 'https://shopapp-77921.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<Orderitem> loadOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    
    if(extractedData==null){
        return;
    }
    extractedData.forEach((orderId, orderData) {
      loadOrders.add(
        Orderitem(
          id: orderId,
          amount: orderData['amount'],
          date: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                    id: e['id'],
                    price: e['price'],
                    quant: e['quantity'],
                    title: e['title']),
              )
              .toList(),
        ),
      );
    });
    _orders=loadOrders.reversed.toList();
    notifyListeners();
  }
}
