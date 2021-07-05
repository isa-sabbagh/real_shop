import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:real_shop/Providers/auth.dart';
import 'package:real_shop/Providers/cart.dart';
import 'package:real_shop/Providers/orders.dart';
import 'package:real_shop/Providers/product.dart';
import 'package:real_shop/Screens/product_detail_screen.dart';
import 'package:real_shop/Screens/splash_screen.dart';

import 'Providers/products.dart';
import 'Screens/auth_screen.dart';
import 'Screens/cart_screen.dart';
import 'Screens/edit_product_screen.dart';
import 'Screens/orders_screen.dart';
import 'Screens/product_overview_screen.dart';
import 'Screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (_) => Products(),
              update: (ctx, authValue, previousProducts) => previousProducts
                ..gtData(authValue.token, authValue.userId,
                    previousProducts == null ? null : previousProducts.items)),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (_) => Orders(),
              update: (ctx, authValue, previousOrders) => previousOrders
                ..gtData(authValue.token, authValue.userId,
                    previousOrders == null ? null : previousOrders.orders)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Real Shop',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato'),
            home:
            //  MyHomePage(),

             auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authSnapshot) =>
                        authSnapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
              CartScreen.routeName: (_) => CartScreen(),
              OrderScreen.routeName: (_) => OrderScreen(),
              UserProductScreen.routeName: (_) => UserProductScreen(),
              EditProductScreen.routeName: (_) => EditProductScreen(),
            },
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController myAnimation;
  @override
  void initState() {
    super.initState();
    myAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: InkWell(
                onTap: () => myAnimation.isCompleted
                    ? myAnimation.reverse()
                    : myAnimation.forward(),
                child: AnimatedIcon(
                    icon: AnimatedIcons.ellipsis_search,
                    size: 100,
                    progress: myAnimation))));
  }
}
