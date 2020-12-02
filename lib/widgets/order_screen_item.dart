import 'package:flutter/material.dart';
import 'package:yooutlet/providers/orders.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderScreenItem extends StatefulWidget {
  final OrderItem order;

  OrderScreenItem(this.order);

  @override
  _OrderScreenItemState createState() => _OrderScreenItemState();
}

class _OrderScreenItemState extends State<OrderScreenItem> {
  var _expanded = false;

  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '₹ ${widget.order.amount}',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime),
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 15,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_expanded
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded),
              color: Theme.of(context).accentColor,
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.cartItems.length * 20.0 + 10, 100),
              child: ListView(
                  children: widget.order.cartItems
                      .map((items) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${items.title} ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${items.quantity} unit ₹ ${items.price},',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ))
                      .toList()),
            ),
        ],
      ),
    );
  }
}
