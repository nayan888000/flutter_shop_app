import '../provider/product_provider.dart';
import 'package:flutter/material.dart';


import './product_item.dart';

import 'package:provider/provider.dart';


class ProductGrid extends StatelessWidget {
  
final bool showOnlyFavorites;

ProductGrid(this.showOnlyFavorites);
  
  @override
  Widget build(BuildContext context) {

    final productsData=Provider.of<Products>(context);
    final products=showOnlyFavorites ? productsData.favoriteItems :  productsData.items;

 
   return  GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
            //create: (c) => products[index], 
            value: products[index],
            child: ProductItem(
            //title: products[index].title,
            //imageUrl: products[index].imageUrl,
            //id: products[index].id,
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      );
  }
}