import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final DatabaseReference _productsRef =
      FirebaseDatabase.instance.ref('products');
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  int? _selectedIndex;
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          products = data.entries.map((entry) {
            final value = entry.value as Map;
            return {
              'key': entry.key,
              'id': value['id'] ?? 0,
              'name': value['name'] ?? '',
              'quantity': value['quantity'] ?? 0,
            };
          }).toList();
        });
      } else {
        setState(() {
          products = [];
        });
      }
    });
  }

  void _addProduct() async {
    if (_idController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty) {
      await _productsRef.push().set({
        'id': int.tryParse(_idController.text) ?? 0,
        'name': _nameController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
      });
      _clearFields();
    }
  }

  void _updateProduct() async {
    if (_selectedKey != null &&
        _idController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty) {
      await _productsRef.child(_selectedKey!).update({
        'id': int.tryParse(_idController.text) ?? 0,
        'name': _nameController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
      });
      _clearFields();
      setState(() {
        _selectedIndex = null;
        _selectedKey = null;
      });
    }
  }

  void _deleteProduct() async {
    if (_selectedKey != null) {
      await _productsRef.child(_selectedKey!).remove();
      _clearFields();
      setState(() {
        _selectedIndex = null;
        _selectedKey = null;
      });
    }
  }

  void _showProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(products: products),
      ),
    );
  }

  void _clearFields() {
    _idController.clear();
    _nameController.clear();
    _quantityController.clear();
  }

  void _selectProduct(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedKey = products[index]['key'];
      _idController.text = products[index]['id'].toString();
      _nameController.text = products[index]['name'];
      _quantityController.text = products[index]['quantity'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm (SQLite)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Mã SP',
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên SP',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _updateProduct,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Cập nhật'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _deleteProduct,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Xoá'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _showProducts,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  const Text('Hiển thị'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = _selectedIndex == index;
                  return InkWell(
                    onTap: () => _selectProduct(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        '${product['id']} - ${product['name']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                products.isNotEmpty
                    ? 'Số lượng: ${products[0]['quantity']}'
                    : '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

class ProductListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductListScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiển thị sản phẩm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: products.isEmpty
          ? const Center(
              child: Text('Không có sản phẩm nào'),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Mã SP')),
                  DataColumn(label: Text('Tên SP')),
                  DataColumn(label: Text('Số lượng')),
                ],
                rows: products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(product['id'].toString())),
                      DataCell(Text(product['name'])),
                      DataCell(Text(product['quantity'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
