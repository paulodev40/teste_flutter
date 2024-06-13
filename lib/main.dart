import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShoppingListsPage(),
    );
  }
}

class ShoppingListsPage extends StatefulWidget {
  @override
  _ShoppingListsPageState createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  final List<Map<String, dynamic>> _shoppingLists = [];

  void _addShoppingList(String listName) {
    setState(() {
      _shoppingLists.add({'name': listName, 'items': []});
    });
  }

  void _navigateToAddList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddListPage(
          onAddList: _addShoppingList,
        ),
      ),
    );
  }

  void _navigateToAddItems(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddItemsPage(
          shoppingList: _shoppingLists[index],
          onUpdateList: (updatedList) {
            setState(() {
              _shoppingLists[index] = updatedList;
            });
          },
        ),
      ),
    );
  }

  double _calculateTotal(Map<String, dynamic> shoppingList) {
    double total = 0.0;
    for (var item in shoppingList['items']) {
      total += item['price'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas de Compras'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Insira uma nova lista',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () => _navigateToAddList(context),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _shoppingLists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_shoppingLists[index]['name']),
                  subtitle: Text('Total: \$${_calculateTotal(_shoppingLists[index]).toStringAsFixed(2)}'),
                  onTap: () => _navigateToAddItems(context, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddListPage extends StatefulWidget {
  final Function(String) onAddList;

  AddListPage({required this.onAddList});

  @override
  _AddListPageState createState() => _AddListPageState();
}

class _AddListPageState extends State<AddListPage> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.isNotEmpty) {
      widget.onAddList(_controller.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Lista'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Nome da Lista'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemsPage extends StatefulWidget {
  final Map<String, dynamic> shoppingList;
  final Function(Map<String, dynamic>) onUpdateList;

  AddItemsPage({required this.shoppingList, required this.onUpdateList});

  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void _addItem() {
    if (_itemController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        widget.shoppingList['items'].add({
          'item': _itemController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
        });
        _itemController.clear();
        _priceController.clear();
      });
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var item in widget.shoppingList['items']) {
      total += item['price'];
    }
    return total;
  }

  void _saveList() {
    widget.onUpdateList(widget.shoppingList);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Itens'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: InputDecoration(labelText: 'Item'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Preço'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Adicionar Item'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.shoppingList['items'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.shoppingList['items'][index]['item']),
                    subtitle: Text(
                        'Preço: \$${widget.shoppingList['items'][index]['price'].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Text(
              'Total: \$${_calculateTotal().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _saveList,
              child: Text('Salvar Lista'),
            ),
          ],
        ),
      ),
    );
  }
}
