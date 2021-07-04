import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/Providers/product.dart';
import 'package:real_shop/Providers/products.dart';
import 'package:real_shop/Screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imgUrl;

  const UserProductItem(this.id, this.title, this.imgUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    return ListTile(
        title: Text(title),
        leading: CircleAvatar(backgroundImage: NetworkImage(imgUrl)),
        trailing: Container(
            width: 100,
            child: Row(children: [
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(EditProductScreen.routeName, arguments: id)),
              IconButton(
                  icon: Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (e) {
                      scaffold.showSnackBar(
                          SnackBar(content: Text('Deleting Failed ＞﹏＜')));
                    }
                  })
            ])));
  }
}
