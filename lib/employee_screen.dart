import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maNVController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _luongCBController = TextEditingController();
  final _heSoController = TextEditingController();
  final _phuCapController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('nhanvien');
  
  String? _editingKey;
  bool _isEditing = false;

  @override
  void dispose() {
    _maNVController.dispose();
    _hoTenController.dispose();
    _luongCBController.dispose();
    _heSoController.dispose();
    _phuCapController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _maNVController.clear();
    _hoTenController.clear();
    _luongCBController.clear();
    _heSoController.clear();
    _phuCapController.clear();
    _editingKey = null;
    _isEditing = false;
  }

  double _tinhLuongThucLinh(double luongCB, double heSo, double phuCap) {
    return luongCB * heSo + phuCap;
  }

  Future<void> _themNhanVien() async {
    if (_formKey.currentState!.validate()) {
      final newRef = _dbRef.push();
      await newRef.set({
        'maNV': _maNVController.text,
        'hoTen': _hoTenController.text,
        'luongCB': double.parse(_luongCBController.text),
        'heSo': double.parse(_heSoController.text),
        'phuCap': double.parse(_phuCapController.text),
      });
      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm nhân viên thành công!')),
        );
      }
    }
  }

  Future<void> _capNhatNhanVien() async {
    if (_formKey.currentState!.validate() && _editingKey != null) {
      await _dbRef.child(_editingKey!).update({
        'maNV': _maNVController.text,
        'hoTen': _hoTenController.text,
        'luongCB': double.parse(_luongCBController.text),
        'heSo': double.parse(_heSoController.text),
        'phuCap': double.parse(_phuCapController.text),
      });
      _clearForm();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
      }
    }
  }

  Future<void> _xoaNhanVien(String key) async {
    await _dbRef.child(key).remove();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa nhân viên thành công!')),
      );
    }
  }

  void _chonSuaNhanVien(String key, Map data) {
    setState(() {
      _editingKey = key;
      _isEditing = true;
      _maNVController.text = data['maNV'].toString();
      _hoTenController.text = data['hoTen'].toString();
      _luongCBController.text = data['luongCB'].toString();
      _heSoController.text = data['heSo'].toString();
      _phuCapController.text = data['phuCap'].toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form nhập liệu
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _maNVController,
                    decoration: const InputDecoration(labelText: 'Mã NV'),
                    validator: (v) => v!.isEmpty ? 'Nhập mã NV' : null,
                  ),
                  TextFormField(
                    controller: _hoTenController,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                    validator: (v) => v!.isEmpty ? 'Nhập họ tên' : null,
                  ),
                  TextFormField(
                    controller: _luongCBController,
                    decoration: const InputDecoration(labelText: 'Lương cơ bản'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Nhập lương CB' : null,
                  ),
                  TextFormField(
                    controller: _heSoController,
                    decoration: const InputDecoration(labelText: 'Hệ số'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Nhập hệ số' : null,
                  ),
                  TextFormField(
                    controller: _phuCapController,
                    decoration: const InputDecoration(labelText: 'Phụ cấp'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Nhập phụ cấp' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isEditing ? _capNhatNhanVien : _themNhanVien,
                    child: Text(_isEditing ? 'Cập nhật' : 'Thêm'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Danh sách nhân viên
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
                    return const Center(child: Text('Chưa có nhân viên'));
                  }

                  final Map<dynamic, dynamic> employees = data as Map;
                  final List<MapEntry> employeeList = employees.entries.toList();

                  return ListView.builder(
                    itemCount: employeeList.length,
                    itemBuilder: (context, index) {
                      final entry = employeeList[index];
                      final key = entry.key.toString();
                      final emp = Map<String, dynamic>.from(entry.value);
                      
                      final luongCB = (emp['luongCB'] as num).toDouble();
                      final heSo = (emp['heSo'] as num).toDouble();
                      final phuCap = (emp['phuCap'] as num).toDouble();
                      final luongTL = _tinhLuongThucLinh(luongCB, heSo, phuCap);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            emp['hoTen'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã NV: ${emp['maNV']}'),
                              Text('Lương CB: $luongCB | Hệ số: $heSo |'),
                              Text('Phụ cấp: $phuCap'),
                              Text(
                                '⭐ Lương thực lĩnh: $luongTL',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _chonSuaNhanVien(key, emp),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _xoaNhanVien(key),
                              ),
                            ],
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
