import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/orders.dart';
import '../Providers/cart.dart' show Cart;
import '../Widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = './cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    return Scaffold(
        appBar: AppBar(title: Text('Your Cart')),
        body: Column(children: [
          Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Chip(
                            label: Text(
                                '${cart.totalAmount.toStringAsFixed(2)} \$',
                                style: TextStyle(color: Colors.white)),
                            backgroundColor: Theme.of(context).primaryColor),
                        OrderButton(cart: cart)
                      ]))),
          SizedBox(height: 10),
          Expanded(
              child: ListView.builder(
                  itemBuilder: (ctx, int index) => CartItem(
                        cart.items.values.toList()[index].id,
                        cart.items.keys.toList()[index],
                        cart.items.values.toList()[index].price,
                        cart.items.values.toList()[index].quantity,
                        cart.items.values.toList()[index].title,
                      ),
                  itemCount: cart.items.length))
        ]));
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;

  const OrderButton({@required this.cart});
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: _isLoading ? CircularProgressIndicator() : Text('Order Now'),
        onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : () async {
                setState(() => _isLoading = true);
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(),
                  widget.cart.totalAmount,
                );
                setState(() => _isLoading = false);
                widget.cart.clear();
              },
        textColor: Theme.of(context).primaryColor);
  }
}
