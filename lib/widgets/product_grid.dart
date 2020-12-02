import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_providers.dart';
import './product_item.dart';

// Class for displaying Grid View
class ProductGrid extends StatelessWidget {
  final itemWidth, itemHeight;
  final bool showOnlyFavorites;

  const ProductGrid(this.itemWidth, this.itemHeight, this.showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    final productProviderData = Provider.of<ProductsProvider>(context);
    final products = showOnlyFavorites?
        productProviderData.onlyFavoritesItems : // if true show only Favorites
        productProviderData.items; // if false show All
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      //Use ChangeNotifierProvider. value if you have already created an instance
      // of the ChangeNotifier class. ... In that case, you wouldn't want to
      // create a whole new instance of your ChangeNotifier because you would be
      // wasting any initialization work that you had already done. Using the
      // ChangeNotifierProvider.
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(
            // products[index].id,
            // products[i].title,
            // products[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
