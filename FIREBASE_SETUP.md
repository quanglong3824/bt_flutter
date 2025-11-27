# Hướng dẫn cấu hình Firebase Realtime Database

## Bước 1: Cấu hình Firebase Realtime Database Rules

Truy cập Firebase Console: https://console.firebase.google.com/project/exercise-app-85b41/database

Chọn **Realtime Database** → **Rules** và cập nhật rules như sau:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**Lưu ý**: Rules trên cho phép đọc/ghi công khai, chỉ dùng cho mục đích học tập. Trong production nên sử dụng authentication.

## Bước 2: Cấu trúc dữ liệu

### Employees (Nhân viên)
```
employees/
  ├── {key1}/
  │   ├── id: "20110468"
  │   ├── name: "Nguyen Kim Hanh"
  │   └── salary: 20300000.0
  └── {key2}/
      ├── id: "12345670"
      ├── name: "Nguyen Van A"
      └── salary: 10300000.0
```

### Products (Sản phẩm)
```
products/
  ├── {key1}/
  │   ├── id: 1
  │   ├── name: "Mi"
  │   └── quantity: 3
  └── {key2}/
      ├── id: 2
      ├── name: "Gao"
      └── quantity: 5
```

## Bước 3: Chạy ứng dụng

### Web
```bash
flutter run -d chrome
```

### Mobile (nếu đã cấu hình Android/iOS)
```bash
flutter run
```

## Tính năng đã tích hợp

### BÀI 1: Tính lương nhân viên
- ✅ Thêm nhân viên mới (tính lương tự động từ lương cơ bản, hệ số, phụ cấp)
- ✅ Sửa thông tin nhân viên
- ✅ Xóa nhân viên
- ✅ Hiển thị danh sách nhân viên realtime
- ✅ Dữ liệu đồng bộ với Firebase Realtime Database

### BÀI 2: Quản lý sản phẩm
- ✅ Thêm sản phẩm mới
- ✅ Cập nhật thông tin sản phẩm
- ✅ Xóa sản phẩm
- ✅ Hiển thị danh sách sản phẩm
- ✅ Xem chi tiết sản phẩm trong bảng
- ✅ Dữ liệu đồng bộ với Firebase Realtime Database

## Packages đã sử dụng

- `firebase_core: ^3.6.0` - Firebase Core SDK
- `firebase_database: ^11.1.4` - Firebase Realtime Database

## Lưu ý

- Ứng dụng hiện tại chỉ hỗ trợ Web platform
- Để hỗ trợ Android/iOS, cần chạy lại `flutterfire configure` với package name hợp lệ
- Dữ liệu được lưu trữ và đồng bộ realtime trên Firebase
- Tất cả thay đổi sẽ được cập nhật ngay lập tức cho tất cả người dùng
