import 'package:flutter/material.dart';
import 'package:shopsqlite/data/models/models.dart';
import 'package:shopsqlite/data/datasources/local/shop_database.dart';

class ProductsList extends StatefulWidget {
  ProductsList({super.key});

  @override
  State<ProductsList> createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  List<Product> products = [
    Product(id: 1, name: "Polo", description: "Esto es un polo", price: 40),
    Product(id: 2, name: "Polo 2", description: "Esto es un polo", price: 60),
    Product(id: 3, name: "Polo 3", description: "Esto es un polo", price: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            await addToCart(products[index]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Producto agregado"),
                duration: Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            color: Colors.amber[900],
            child: _ProductItem(product: products[index]),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(height: 5),
      itemCount: products.length,
    );
  }
}

Future<void> addToCart(Product product) async {
  final item = CartItem(
    id: product.id,
    name: product.name,
    price: product.price,
    quantity: 12,
  );
  await ShopDatabase.instance.insert(item);
}

class _ProductItem extends StatelessWidget {
  final Product product;
  _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Image.asset('assets/images/04.jpg'),
            ),
            Padding(padding: EdgeInsets.only(right: 15, left: 3)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name),
                Text(product.description),
                Text("\$ ${product.price}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
