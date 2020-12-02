import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/providers/auth.dart';
import 'package:yooutlet/providers/cart.dart';
import 'package:yooutlet/providers/products_providers.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  static const Color background = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    // listen = false because if we tap favorite button the product don't
    // have to listen and does not need to rebuild
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Image.network(product.imageUrl, fit: BoxFit.cover)),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          //Consumer is used when some parts of widget is changed
          // Example in this only favorite button is performing action
          leading: Consumer<Product>(
            builder: (context, product, _) =>
                IconButton(
                  // _ because it will not rebuild whole button
                  icon: Icon(
                    product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: background,
                  onPressed: () {
                    product.toggleFavorite(authData.token, authData.userId);
                  },
                ),
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: background,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added item to cart !',
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: (){
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  )
              );
            },
          ),
        ),
      ),
    );
  }
}
