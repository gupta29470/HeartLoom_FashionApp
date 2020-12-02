import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/providers/auth.dart';
import 'package:yooutlet/screens/order_screen.dart';
import 'package:yooutlet/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello !'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop_rounded),
            title: Text(
              'Shop'
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed('/'); // home page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment_rounded),
            title: Text(
                'Your Orders'
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName); // home page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit_rounded),
            title: Text(
                'Manage Products'
            ),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName); // home page
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app_rounded),
            title: Text(
                'Logout'
            ),
            onTap: (){
              Navigator.of(context).pop(); // close app drawer
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logOut(); // home page
            },
          ),
        ],
      ),
    );
  }

}