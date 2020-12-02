import 'package:flutter/material.dart';
import 'package:yooutlet/providers/cart.dart';
import 'package:yooutlet/screens/auth_screen.dart';
import 'package:yooutlet/screens/cart_screen.dart';
import 'package:yooutlet/screens/edit_product_screen.dart';
import 'package:yooutlet/screens/order_screen.dart';
import 'package:yooutlet/screens/product_detail_screen.dart';
import 'package:yooutlet/screens/product_overview_screen.dart';
import 'package:yooutlet/screens/splash_screen.dart';
import 'package:yooutlet/screens/user_products_screen.dart';
import './providers/products_providers.dart';
import 'package:provider/provider.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp()); // running application
}

class MyApp extends StatelessWidget {
  static const Color colorPrimary = const Color(0xFFFF6F00); // app bar color
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // For nested providers
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          // Widget
          update: (context, auth, previousProducts) => ProductsProvider(
              auth.token,
              previousProducts == null ? [] : previousProducts.items,
              auth.userId),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (context, auth, previousOrders) => Orders(
              auth.token,
              previousOrders == null ? [] : previousOrders.getOrders,
              auth.userId),
        ),
      ], // instance of ChangeNotifier
      // if we use existing object we can use ProductsProvider.value
      // we want to rebuilt product overview screen
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Heart Loom',
          theme: ThemeData(
            primaryColor: colorPrimary,
            accentColor: Colors.orangeAccent,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            // "/productdetailscreen": (context) => ProductDetailScreen(title),
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
