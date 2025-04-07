import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsqlite/my_cart.dart';
import 'package:shopsqlite/notifier.dart';
import 'package:shopsqlite/products_list.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: ChangeNotifierProvider(
        create: (context) => CartNotifier(),
        child: Scaffold(
          appBar: AppBar(title: Text("Shop Sqlite")),
          body: _selectedIndex == 0 ? ProductsList() : MyCart(),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: "Shopping",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "My cart",
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
