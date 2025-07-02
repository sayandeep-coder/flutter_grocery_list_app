import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
// import 'package:shopping_list_app/models/grocey_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/grocey_item.dart';

class NewItems extends StatefulWidget{
  const NewItems({super.key});

  @override
  State<NewItems> createState() {
    return _NewIteams();
  }
}

class _NewIteams extends State<NewItems> {

  final _formKey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enterQuantity = 1;
  var _selectedCtaegory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
   if( _formKey.currentState!.validate()){
    _isSending = true;
     _formKey.currentState!.save();
     final url = Uri.https('shopping-list-app-27068-default-rtdb.firebaseio.com', 'shopping-list.json');
     final response = await http.post(url, 
     headers: {
      'content-type' : 'application/json',
     }, 
     body: json.encode({
          'name': _enteredName, 
          'quantity': _enterQuantity, 
          'category': _selectedCtaegory.title,
     },
    ),
  );
      final Map<String, dynamic> resData = json.decode(response.body);
      if(!context.mounted) {
        return;
      } 
    // Navigator.of(context).pop();
     Navigator.of(context).pop(
      GroceryItem(
        id: resData['name'], 
        name: _enteredName, 
        quantity: _enterQuantity, 
        category: _selectedCtaegory
      )
     );
   }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add your groceries..'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(
                  label: Text('Name'),
                ),
                validator : (value) {
                  if (
                    value == null || 
                    value.isEmpty || 
                    value.trim().length <= 1 || 
                    value.trim().length > 50 
                  ) 
                    {
                      return 'Must be between 1 - 50 characters..';
                    }
                  return null;  
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enterQuantity.toString(),
                      validator : (value) {
                      if (
                        value == null || 
                        value.isEmpty || 
                        int.tryParse(value) == null || 
                        int.tryParse(value)! <= 0
                      ) 
                        {
                          return 'Number must be positive..';
                        }
                      return null;  
                    },
                    onSaved: (value) {
                      _enterQuantity = int.parse(value!);
                    },
                   ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCtaegory,
                      items: [
                        for(final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6,),
                                Text(category.value.title),
                              ],
                            )
                        )
                      ], 
                      onChanged: (value) {
                        setState(() {
                          _selectedCtaegory = value!;
                        });
                      }
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending ? null : () {
                      _formKey.currentState!.reset();
                    }, 
                    child: Text('Reset')
                  ),
                  const SizedBox(width: 8,),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem, 
                    child: _isSending ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(),
                    ) : Text('Add item'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}