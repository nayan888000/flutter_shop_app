import 'package:app4/screens/edit_product_screen.dart';
import './screens/splash_screen.dart';
import 'package:app4/widgets/user_product_item.dart';
import './screens/auth_screen.dart';
import './screens/order_screen.dart';
import './provider/orders.dart';
import './provider/auth.dart';
import './screens/cart_screen.dart';
import './screens/user_products_screen.dart';
import './provider/cart.dart';
import './screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import './screens/products_overview_screen.dart';
import './provider/product_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProduct) => Products(
            auth.token,
            previousProduct == null ? [] : previousProduct.items,
            auth.userId,
          ),
        ),
        // ChangeNotifierProvider.value(
        // value:Products(),
        //),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrder) => Orders(
            auth.token,
            previousOrder == null ? [] : previousOrder.orders,
            auth.userId,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.blue,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
          },
        ),
      ),
    );
  }
}
