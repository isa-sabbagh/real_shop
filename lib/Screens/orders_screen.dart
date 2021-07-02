import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/app_drawer.dart';
import '../Widgets/order_item.dart';
import '../Providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routeName = './order';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.error != null) {
                return Center(child: Text('An error'));
              } else {
                return Consumer<Orders>(
                    builder: (ctx, orderData, childd) => ListView.builder(
                        itemBuilder: (BuildContext context, int index) =>
                            OrderItem(orderData.orders[index]),
                        itemCount: orderData.orders.length));
              }
            }
          }),
    );
  }
}
