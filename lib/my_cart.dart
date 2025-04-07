import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsqlite/models.dart';
import 'package:shopsqlite/notifier.dart';
import 'package:shopsqlite/shop_database.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cart, child) {
        return FutureBuilder(
          future: ShopDatabase.instance.getAllItems(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<CartItem>> snapshot,
          ) {
            if (snapshot.hasData) {
              List<CartItem> cartItems = snapshot.data!;
              return cartItems.isEmpty
                  ? Center(
                    child: Text(
                      "No hay productos en tu carro",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                  : ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        color: Colors.yellow[800],
                        child: _CartItem(cartItems[index]),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) =>
                            const Divider(height: 10),
                    itemCount: cartItems.length,
                  );
            } else {
              return const Center(
                child: Text(
                  "No hay productos en tu carro",
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem cartItem;

  const _CartItem(this.cartItem);
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 14, color: Colors.deepPurple),
      child: SizedBox(
        child: Row(
          children: [
            Image.asset('assets/images/04.jpg', width: 120),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(cartItem.name),
                    Text("\$ ${cartItem.price.toString()}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("\$ ${cartItem.quantity.toString()} unidades"),
                        ElevatedButton(
                          onPressed: () {
                            cartItem.quantity++;
                            ShopDatabase.instance.update(cartItem);
                            Provider.of<CartNotifier>(
                              context,
                              listen: false,
                            ).shouldRefresh();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            minimumSize: Size.zero,
                          ),
                          child: Text("+"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            cartItem.quantity--;
                            if (cartItem.quantity == 0) {
                              await ShopDatabase.instance.delete(cartItem.id);
                            } else {
                              await ShopDatabase.instance.update(cartItem);
                            }
                            ShopDatabase.instance.update(cartItem);
                            Provider.of<CartNotifier>(
                              context,
                              listen: false,
                            ).shouldRefresh();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            minimumSize: Size.zero,
                          ),
                          child: Text("-"),
                        ),
                      ],
                    ),
                    Text("total \$ ${cartItem.totalPrice}"),
                    ElevatedButton(
                      onPressed: () async {
                        await ShopDatabase.instance.delete(cartItem.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Producto eliminado"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Provider.of<CartNotifier>(
                          context,
                          listen: false,
                        ).shouldRefresh();
                      },
                      child: Text("Eliminar"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
