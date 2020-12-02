import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yooutlet/providers/product.dart';
import 'package:yooutlet/providers/products_providers.dart';
import 'package:yooutlet/screens/user_products_screen.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageController = TextEditingController();

  final _form = GlobalKey<FormState>();
  var editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var Init = true;
  var isLoading = false;
  var editValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageURLFocusNode.addListener(updateImageURl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (Init) {
      // getting product id
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        // finding product with help of id
        editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        // if we edit form will by default fill with existing values
        editValues = {
          'title': editedProduct.title,
          'price': editedProduct.price.toString(),
          'description': editedProduct.description,
          'imageUrl': '',
        };
        _imageController.text = editedProduct.imageUrl;
      }
    }
    Init = false;
    super.didChangeDependencies();
  }

  void dispose() {
    _imageURLFocusNode.removeListener(updateImageURl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageController.dispose();
    _imageURLFocusNode.dispose();
    super.dispose();
  }

  void updateImageURl() {
    if (!_imageURLFocusNode.hasFocus) {
      if (!_imageController.text.startsWith('http') ||
          !_imageController.text.startsWith('https')) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProducts(editedProduct.id, editedProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An error occured !'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(UserProductsScreen.routeName);
                },
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save_rounded), onPressed: saveForm),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextFormField(
                        initialValue: editValues['title'],
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 15,
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                            title: value,
                            price: editedProduct.price,
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextFormField(
                        initialValue: editValues['price'],
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please provide valid price';
                          }
                          if (double.tryParse(value) <= 0) {
                            return 'Please provide a price greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                            title: editedProduct.title,
                            price: double.parse(value),
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextFormField(
                        initialValue: editValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a description';
                          }
                          if (value.length < 10) {
                            return 'Description should be 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                            title: editedProduct.title,
                            price: editedProduct.price,
                            description: value,
                            imageUrl: editedProduct.imageUrl,
                            id: editedProduct.id,
                            isFavorite: editedProduct.isFavorite,
                          );
                        },
                      ),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 180,
                          height: 180,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          child: _imageController.text.isEmpty
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  child: CircleAvatar(
                                    radius: 85,
                                    backgroundImage:
                                        AssetImage('assets/Image/whiteImg.jpg'),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  child: CircleAvatar(
                                    radius: 85,
                                    backgroundImage:
                                        NetworkImage(_imageController.text),
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Image URL',
                                labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 15,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageController,
                              focusNode: _imageURLFocusNode,
                              /* onFieldSubmitted: (_) {
                          saveForm();
                        }, */
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide a image URL';
                                }
                                if (!value.startsWith('http') ||
                                    !value.startsWith('https')) {
                                  return 'Please enter valid URL';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                editedProduct = Product(
                                  title: editedProduct.title,
                                  price: editedProduct.price,
                                  description: editedProduct.description,
                                  imageUrl: value,
                                  id: editedProduct.id,
                                  isFavorite: editedProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
