import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/screens/edit_product_screen.dart';
import 'package:yooutlet/widgets/app_drawer.dart';
import 'package:yooutlet/widgets/user_product_item.dart';
import '../providers/products_providers.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-product-screen';

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => refreshProducts(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<ProductsProvider>(
                    builder: (context, productsData, child) => ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          UserProductItem(
                              productsData.items[index].id,
                              productsData.items[index].title,
                              productsData.items[index].imageUrl),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
