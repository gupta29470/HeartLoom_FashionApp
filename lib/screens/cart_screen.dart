import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/cart_screen_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cartscreen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '₹ ${cart.totalAmount.toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) => CartScreenItem(
                cart.cartItems.values.toList()[index].id,
                // fetching product key to delete product
                cart.cartItems.keys.toList()[index],
                cart.cartItems.values.toList()[index].title,
                cart.cartItems.values.toList()[index].price,
                cart.cartItems.values.toList()[index].quantity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: isLoading
          ? CircularProgressIndicator()
          : Text(
              'ORDER NOW',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
      onPressed: (widget.cart.totalAmount <= 0 || isLoading)
          ? null //if it is 0 and become null flutter disable flat button
          : () async {
              setState(() {
                isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrders(
                  widget.cart.cartItems.values.toList(),
                  widget.cart.totalAmount);
              setState(() {
                isLoading = false;
              });
              widget.cart.clearCart();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
