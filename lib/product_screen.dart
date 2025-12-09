import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _maSPController = TextEditingController();
  final _tenSPController = TextEditingController();
  final _soLuongController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sanpham');

  String? _selectedKey;

  @override
  void dispose() {
    _maSPController.dispose();
    _tenSPController.dispose();
    _soLuongController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _maSPController.clear();
    _tenSPController.clear();
    _soLuongController.clear();
    _selectedKey = null;
    setState(() {});
  }

  Future<void> _themSanPham() async {
    if (_maSPController.text.isEmpty ||
        _tenSPController.text.isEmpty ||
        _soLuongController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    final newRef = _dbRef.push();
    await newRef.set({
      'maSP': _maSPController.text,
      'tenSP': _tenSPController.text,
      'soLuong': int.tryParse(_soLuongController.text) ?? 0,
    });
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sản phẩm thành công!')),
      );
    }
  }

  Future<void> _capNhatSanPham() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để cập nhật!')),
      );
      return;
    }

    if (_maSPController.text.isEmpty ||
        _tenSPController.text.isEmpty ||
        _soLuongController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    await _dbRef.child(_selectedKey!).update({
      'maSP': _maSPController.text,
      'tenSP': _tenSPController.text,
      'soLuong': int.tryParse(_soLuongController.text) ?? 0,
    });
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật sản phẩm thành công!')),
      );
    }
  }

  Future<void> _xoaSanPham() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn sản phẩm để xóa!')),
      );
      return;
    }

    await _dbRef.child(_selectedKey!).remove();
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa sản phẩm thành công!')),
      );
    }
  }

  void _chonSanPham(String key, Map data) {
    setState(() {
      _selectedKey = key;
      _maSPController.text = data['maSP'].toString();
      _tenSPController.text = data['tenSP'].toString();
      _soLuongController.text = data['soLuong'].toString();
    });
  }

  void _hienThiSanPham() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductDisplayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sản phẩm'),
        backgroundColor: const Color(0xFF7B68EE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField nhập mã sản phẩm
            TextField(
              controller: _maSPController,
              decoration: const InputDecoration(
                hintText: 'Nhập mã sản phẩm',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // TextField nhập tên sản phẩm
            TextField(
              controller: _tenSPController,
              decoration: const InputDecoration(
                hintText: 'Nhập tên sản phẩm',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // TextField nhập số lượng
            TextField(
              controller: _soLuongController,
              decoration: const InputDecoration(
                hintText: 'Nhập số lượng',
                border: UnderlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Nút Thêm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _themSanPham,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Thêm', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            // Nút Cập nhật
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _capNhatSanPham,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cập nhật', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            // Nút Xóa
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _xoaSanPham,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Xóa', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            // Nút Hiển thị
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hienThiSanPham,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B68EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Hiển thị', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            // Danh sách sản phẩm
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.snapshot.value;
                  if (data == null) {
                    return const Center(child: Text('Chưa có sản phẩm'));
                  }

                  final Map<dynamic, dynamic> products = data as Map;
                  final List<MapEntry> productList = products.entries.toList();

                  return ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final entry = productList[index];
                      final key = entry.key.toString();
                      final product = Map<String, dynamic>.from(entry.value);

                      return InkWell(
                        onTap: () => _chonSanPham(key, product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedKey == key
                                ? Colors.grey.shade200
                                : Colors.transparent,
                          ),
                          child: Text(
                            '${product['maSP']}. ${product['tenSP']} - ${product['soLuong']} sản phẩm',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Màn hình hiển thị sản phẩm (widget khác)
class ProductDisplayScreen extends StatelessWidget {
  const ProductDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref('sanpham');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Sản phẩm'),
        backgroundColor: const Color(0xFF7B68EE),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.snapshot.value;
          if (data == null) {
            return const Center(child: Text('Chưa có sản phẩm'));
          }

          final Map<dynamic, dynamic> products = data as Map;
          final List<MapEntry> productList = products.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final entry = productList[index];
              final product = Map<String, dynamic>.from(entry.value);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    product['tenSP'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Mã SP: ${product['maSP']}'),
                  trailing: Text(
                    '${product['soLuong']} SP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B68EE),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
