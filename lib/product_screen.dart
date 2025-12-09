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
  List<String> _existingMaSP = []; // Danh sách mã SP đã tồn tại

  @override
  void initState() {
    super.initState();
    _loadExistingMaSP();
  }

  // Load danh sách mã SP để kiểm tra trùng
  void _loadExistingMaSP() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map<dynamic, dynamic> products = data as Map;
        _existingMaSP = products.entries
            .map((e) => (e.value as Map)['maSP'].toString())
            .toList();
      } else {
        _existingMaSP = [];
      }
    });
  }

  // Kiểm tra null/empty
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống!';
    }
    return null;
  }

  // Kiểm tra số lượng phải là số dương
  String? _validateSoLuong(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lượng không được để trống!';
    }
    final soLuong = int.tryParse(value);
    if (soLuong == null) {
      return 'Số lượng phải là số!';
    }
    if (soLuong < 0) {
      return 'Số lượng không được âm!';
    }
    return null;
  }

  // Kiểm tra trùng mã SP
  String? _validateMaSPTrung(String maSP) {
    // Nếu đang edit, bỏ qua mã SP hiện tại
    if (_selectedKey != null) {
      return null; // Cho phép giữ nguyên mã khi cập nhật
    }
    if (_existingMaSP.contains(maSP.trim())) {
      return 'Mã sản phẩm đã tồn tại!';
    }
    return null;
  }

  // Kiểm tra mã SP hợp lệ (chỉ chứa chữ và số)
  String? _validateMaSPFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mã SP không được để trống!';
    }
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Mã SP chỉ được chứa chữ và số!';
    }
    return null;
  }

  // Validate tất cả các trường
  bool _validateAll() {
    final errors = <String>[];

    // Kiểm tra null/empty
    final maSPError = _validateNotEmpty(_maSPController.text, 'Mã SP');
    if (maSPError != null) errors.add(maSPError);

    final tenSPError = _validateNotEmpty(_tenSPController.text, 'Tên SP');
    if (tenSPError != null) errors.add(tenSPError);

    final soLuongError = _validateSoLuong(_soLuongController.text);
    if (soLuongError != null) errors.add(soLuongError);

    // Kiểm tra format mã SP
    if (maSPError == null) {
      final formatError = _validateMaSPFormat(_maSPController.text);
      if (formatError != null) errors.add(formatError);
    }

    // Kiểm tra trùng mã SP (chỉ khi thêm mới)
    if (maSPError == null && _selectedKey == null) {
      final trungError = _validateMaSPTrung(_maSPController.text);
      if (trungError != null) errors.add(trungError);
    }

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

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
    if (!_validateAll()) return;

    // Kiểm tra trùng mã SP một lần nữa trước khi thêm
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final isDuplicate = data.values.any(
        (v) => (v as Map)['maSP'].toString().trim() == _maSPController.text.trim(),
      );
      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã sản phẩm đã tồn tại!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final newRef = _dbRef.push();
    await newRef.set({
      'maSP': _maSPController.text.trim(),
      'tenSP': _tenSPController.text.trim(),
      'soLuong': int.tryParse(_soLuongController.text) ?? 0,
    });
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm sản phẩm thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _capNhatSanPham() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn sản phẩm để cập nhật!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_validateAll()) return;

    // Kiểm tra chéo: mã SP mới có trùng với SP khác không
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final isDuplicate = data.entries.any((entry) {
        if (entry.key.toString() == _selectedKey) return false; // Bỏ qua chính nó
        return (entry.value as Map)['maSP'].toString().trim() == _maSPController.text.trim();
      });
      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã sản phẩm đã tồn tại ở sản phẩm khác!'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    await _dbRef.child(_selectedKey!).update({
      'maSP': _maSPController.text.trim(),
      'tenSP': _tenSPController.text.trim(),
      'soLuong': int.tryParse(_soLuongController.text) ?? 0,
    });
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật sản phẩm thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _xoaSanPham() async {
    if (_selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn sản phẩm để xóa!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hiển thị dialog xác nhận trước khi xóa
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${_tenSPController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _dbRef.child(_selectedKey!).remove();
    _clearForm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa sản phẩm thành công!'),
          backgroundColor: Colors.green,
        ),
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
