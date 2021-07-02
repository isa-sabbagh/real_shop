import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:real_shop/Widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../Providers/products.dart';
import '../Widgets/user_product_item.dart';
import '../Screens/edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = './user-product';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Your Products'), actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName),
              icon: Icon(Icons.add))
        ]),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: (ctx, AsyncSnapshot snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        child: Consumer<Products>(
                            builder: (ctx, productsData, _) => Padding(
                                padding: EdgeInsets.all(8),
                                child: ListView.builder(
                                    itemCount: productsData.items.length,
                                    itemBuilder: (_, int index) =>
                                        Column(children: [
                                          UserProductItem(
                                              productsData.items[index].id,
                                              productsData.items[index].title,
                                              productsData.items[index].imgUrl),
                                          Divider()
                                        ])))),
                        onRefresh: () => _refreshProducts(context))));
  }
}
