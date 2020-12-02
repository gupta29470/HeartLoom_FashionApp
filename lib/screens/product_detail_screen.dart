import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_providers.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context).settings.arguments
        as String; // extracting product
    final loadedProducts = Provider.of<ProductsProvider>(
      context,
      listen: false, // if other widget is changed this will not rebuilt.
    ).findById(product); // fetching product
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProducts.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 35,
                right: 20,
                left: 20,
                bottom: 15,
              ),
              child: Card(
                margin: const EdgeInsets.all(5.0),
                //clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    loadedProducts.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(
              '₹ ${loadedProducts.price}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                loadedProducts.description,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
