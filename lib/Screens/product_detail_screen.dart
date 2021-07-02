
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../Providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = './product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadProduct =
        Provider.of<Products>(context, listen: false).finddById(productId);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  title: Text(loadProduct.title),
                  background: Hero(
                      tag: loadProduct.id,
                      child: Image.network(loadProduct.imgUrl,
                          fit: BoxFit.cover)))),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 10),
            Text(
              '${loadProduct.price} \$',
                textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadProduct.desc,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(height: 800,)
          ]))
        ],
      ),
    );
  }
}
