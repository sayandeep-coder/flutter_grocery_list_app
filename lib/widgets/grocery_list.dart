import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocey_item.dart';
import 'package:shopping_list_app/widgets/new_items.dart';
import 'package:http/http.dart' as http;


class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {

  List<GroceryItem> _grocery = [];
  var _isLoading = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https('shopping-list-app-27068-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'can not fetch the data. try again later...';
          _isLoading = false;
        });
        return;
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
        final categoryValue = item.value['category'];
        if (categoryValue == null) continue;
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == categoryValue,
              orElse: () => categories.entries.first,
            )
            .value;
        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }
      setState(() {
        _grocery = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'can not fetch the data. try again later...';
        _isLoading = false;
      });
    }
  }

  void _addItem() async{
    final newItam = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItems()
      )
    );
    if(newItam == null) {
      return;
    }

    setState(() {
      _grocery.add(newItam);
    });

    _loadItem();
  }
  void _onDismissed(GroceryItem item) async{
    final index = _grocery.indexOf(item);
    setState(() {
      _grocery.remove(item);
    });

    final url = Uri.https('shopping-list-app-27068-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    
    if(response.statusCode <= 400) {
      setState(() {
        _grocery.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('no items were added'),
    );

    if(_isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    if(_grocery.isNotEmpty) {
      content = ListView.builder(
        itemCount: _grocery.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_grocery[index].id),
          onDismissed: (direction) => _onDismissed(_grocery[index]),
          child: ListTile(
            title: Text(_grocery[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _grocery[index].category.color,
            ),
            trailing: Text(_grocery[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
      child: Text(_error!),
    );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your grocery items'),
        actions: [
          IconButton(
            onPressed: _addItem, 
            icon: Icon(Icons.add)
          ),
        ],
      ),
      body: content,
    );
  }
}