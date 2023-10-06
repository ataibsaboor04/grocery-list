import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_list/data/categories.dart';
import 'package:http/http.dart' as http;

import 'package:grocery_list/models/grocery_item.dart';
import 'package:grocery_list/screens/new_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key, required this.title});

  final String title;

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https('grocery-list-app-51ed8-default-rtdb.firebaseio.com',
        'grocery-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categories.entries
                .firstWhere(
                    (element) => element.value.title == item.value['category'])
                .value));
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => const NewItemScreen(title: 'Add a new item')),
      ),
    );

    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('grocery-list-app-51ed8-default-rtdb.firebaseio.com',
        'grocery-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 3),
          content: Text(
            'Error deleting the item.',
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_groceryItems.isEmpty) {
      content = const Center(child: Text('No items added yet.'));
    } else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
            child: const Icon(
              Icons.delete_rounded,
              size: 26,
            ),
          ),
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            leading: Icon(
              Icons.square,
              color: _groceryItems[index].category.color,
              size: 26,
              // color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              _groceryItems[index].name,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    // color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 18,
                  ),
            ),
            onTap: () {},
            trailing: Text(
              _groceryItems[index].quantity.toString(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    // color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 16,
                  ),
            ),
            horizontalTitleGap: 30,
            splashColor: Colors.transparent,
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
        leading: Container(
          padding: const EdgeInsets.all(11.0),
          child: Image.asset(
            'assets/grocery_list.png',
            height: 35,
            width: 35,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Shop',
        child: const Icon(Icons.shopping_cart_outlined),
      ),
      body: content,
    );
  }
}
