import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/providers/products_providers.dart';
import 'package:yooutlet/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.edit_rounded),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  color: Theme.of(context).primaryColor),
              IconButton(
                  icon: Icon(Icons.delete_rounded),
                  onPressed: () {
                    Provider.of<ProductsProvider>(context, listen: false).deleteProducts(id);
                  },
                  color: Theme.of(context).errorColor),
            ],
          ),
        ),
      ),
    );
  }
}
