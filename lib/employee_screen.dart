import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final DatabaseReference _employeesRef =
      FirebaseDatabase.instance.ref('employees');
  List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  void _loadEmployees() {
    _employeesRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          employees = data.entries.map((entry) {
            final value = entry.value as Map;
            return {
              'key': entry.key,
              'id': value['id'] ?? '',
              'name': value['name'] ?? '',
              'salary': (value['salary'] ?? 0).toDouble(),
            };
          }).toList();
        });
      } else {
        setState(() {
          employees = [];
        });
      }
    });
  }

  void _showAddEmployeeDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final salaryController = TextEditingController();
    final coefficientController = TextEditingController();
    final allowanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thêm nhân viên',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Mã NV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên NV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(
                  labelText: 'Lương cơ bản',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: coefficientController,
                decoration: const InputDecoration(
                  labelText: 'Hệ số',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: allowanceController,
                decoration: const InputDecoration(
                  labelText: 'Phụ cấp',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (idController.text.isNotEmpty &&
                          nameController.text.isNotEmpty &&
                          salaryController.text.isNotEmpty) {
                        double baseSalary =
                            double.tryParse(salaryController.text) ?? 0;
                        double coefficient =
                            double.tryParse(coefficientController.text) ?? 1;
                        double allowance =
                            double.tryParse(allowanceController.text) ?? 0;
                        double totalSalary = baseSalary * coefficient + allowance;

                        await _employeesRef.push().set({
                          'id': idController.text,
                          'name': nameController.text,
                          'salary': totalSalary,
                        });
                        
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Thêm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editEmployee(int index) {
    final employee = employees[index];
    final idController = TextEditingController(text: employee['id']);
    final nameController = TextEditingController(text: employee['name']);
    final salaryController =
        TextEditingController(text: employee['salary'].toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sửa nhân viên',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Mã NV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên NV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(
                  labelText: 'Lương',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _employeesRef.child(employee['key']).update({
                        'id': idController.text,
                        'name': nameController.text,
                        'salary': double.tryParse(salaryController.text) ?? 0,
                      });
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteEmployee(int index) {
    final employee = employees[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa nhân viên này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _employeesRef.child(employee['key']).remove();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tính lương nhân viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                '${employee['id']} - ${employee['name']}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Lương: ${employee['salary'].toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editEmployee(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEmployee(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
