import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/providers/cart.dart';
import 'package:yooutlet/providers/products_providers.dart';
import 'package:yooutlet/screens/cart_screen.dart';
import 'package:yooutlet/widgets/app_drawer.dart';
import 'package:yooutlet/widgets/badge.dart';
import '../widgets/product_grid.dart';

// Value for Popup Menu Button
enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var showOnlyFavorites = false; // initially false
  var isInit = true;
  var isLoading = false;

  // ************ Method 1: To Fetch Data *****************
  // Fetching data from firebase and screen renders only once we can use init state
  // Init State runs only one time
  @override
  void initState() {
    // Provider does not work in initState
    // Provider.of<ProductsProvider>(context).fetchAndSetProducts(); // Won't Work

    /*Future.delayed(Duration.zero).then((value) {
      //Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    }); */
    super.initState();
  }

  // ************ Method 2: To Fetch Data *****************
  // Did Change Dependencies run multiple times
  @override
  void didChangeDependencies() {
    if (isInit) {
      isLoading = true;
      Provider.of<ProductsProvider>(context)
          .fetchAndSetProducts()
          .then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // height and width of each item
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 5;
    //final double itemHeight = (size.height - kToolbarHeight - 24) / 2.6;
    final double itemWidth = (size.width) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Heart Loom'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                // to reflect change
                if (selectedValue == FilterOptions.Favorites) {
                  showOnlyFavorites = true;
                } else {
                  showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert_rounded,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites),
              PopupMenuItem(child: Text('Show All'), value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, child) => Badge(
              child: child,
              value: cart.countItem.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart_rounded),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(
              itemHeight, itemWidth, showOnlyFavorites), // passing to grid
    );
  }
}
