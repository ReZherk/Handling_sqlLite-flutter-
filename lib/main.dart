import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsqlite/presentation/pages/my_cart.dart';
import 'package:shopsqlite/presentation/notifiers/notifier.dart';
import 'package:shopsqlite/presentation/pages/products_list.dart';

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
        create: (_) => CartNotifier(),
        child: Scaffold(
          appBar: AppBar(title: Text("Shop Sqlite")),
          body: _selectedIndex == 0 ? ProductsList() : MyCart(),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_work),
                label: "Catalog",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "My cart",
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFFF7374F),
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
