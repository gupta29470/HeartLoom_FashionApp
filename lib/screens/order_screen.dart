import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/widgets/app_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_screen_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order-screen';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var isLoading = false;

  void initState() {
    isLoading = true;

    Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Orders',
        ),
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orderData.getOrders.length,
              itemBuilder: (context, index) =>
                  OrderScreenItem(orderData.getOrders[index]),
            ),
    );
  }
}
