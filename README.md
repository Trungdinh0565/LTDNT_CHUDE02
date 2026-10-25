# LTDNT_CHUDE02 - Lập trình Bất đồng bộ với Future & Stream trong Flutter
---

*Báo cáo tuần - Môn lập trình đa nền tảng*

---

## 1. Giới thiệu tổng quan
Dự án **Countdown Timer App** (Đồng hồ đếm ngược) được xây dựng phục vụ môn học **Lập trình đa nền tảng - Chủ đề 02**.  
Ứng dụng minh họa trực quan và toàn diện cách áp dụng các cơ chế xử lý bất đồng bộ cốt lõi trong Flutter và Dart, kết hợp với kiến trúc **Clean Architecture** và mô hình quản lý trạng thái **BLoC/Cubit**:

- **Future & async/await:** Giả lập tác vụ bất đồng bộ khởi tạo dữ liệu ban đầu (`getInitialValue()`).
- **StreamController & Timer:** Phát luồng dữ liệu thời gian thực định kỳ mỗi giây (`stream`), đếm ngược an toàn về 0 và thông báo hoàn thành.
- **StreamBuilder & BlocBuilder:** Tự động lắng nghe và cập nhật giao diện người dùng theo thời gian thực (real-time UI updates) mà không gây giật lag hay render thừa.
- **Clean Architecture & Dependency Injection:** Phân tách rõ ràng các tầng Domain, Data, Presentation và quản lý phụ thuộc linh hoạt thông qua `get_it`.

---

## 2. Công nghệ và Thư viện sử dụng
- **Flutter SDK** (hỗ trợ đa nền tảng: Android, iOS, Web, Windows, macOS, Linux).
- **Dart Async (`Future`, `Stream`, `StreamController.broadcast()`, `Timer`):** Xử lý tác vụ bất đồng bộ và luồng dữ liệu thời gian.
- **Clean Architecture:** Tách biệt rõ ràng giữa Business Logic, Data và UI.
- **flutter_bloc (`Cubit` & `BlocBuilder`):** Quản lý trạng thái giao diện (`isLoading`, `isRunning`, `isCompleted`).
- **get_it:** Service Locator / Dependency Injection giúp giải phóng phụ thuộc giữa các lớp.

---

## 3. Cấu trúc thư mục dự án
Dự án được tổ chức theo cấu trúc Clean Architecture chuẩn hóa và tinh gọn:

```text
lib/
├── Data/
│   ├── repository_impl.dart      # Triển khai StopWatchRepository với Timer, StreamController.broadcast
│   └── stopWatch_model.dart      # Model kế thừa từ StopWatchEntity
├── Domain/
│   ├── stopWatch_entity.dart     # Thực thể biểu diễn dữ liệu (remainingSeconds, initialSeconds, isCompleted)
│   ├── stopWatch_repository.dart # Interface trừu tượng định nghĩa các phương thức nghiệp vụ
│   └── stopWatch_usecase.dart    # Ca sử dụng (start, pause, reset, setDuration, stream)
├── Presentation/
│   ├── stopWatch_cubit.dart      # Quản lý trạng thái (StopWatchCubit & StopWatchState)
│   └── stopWatch_page.dart       # Giao diện đếm ngược & Dialog nhập thời gian (StreamBuilder + BlocBuilder)
├── injection_container.dart       # Cấu hình Dependency Injection (GetIt) tinh gọn với cú pháp cascade
└── main.dart                     # Điểm khởi chạy ứng dụng (main entry point)
test/
└── widget_test.dart              # Kiểm thử giao diện và kịch bản bất đồng bộ
```
---

## 4. Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu môi trường
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `>=3.13.0`).
- Dart SDK tương ứng đi kèm Flutter.
- Trình biên dịch: Visual Studio Code, Android Studio hoặc Cursor.

### Cách 1: Chạy trực tiếp từ mã nguồn (Source code)
1. **Clone repository:**
   ```bash
   git clone https://github.com/Trungdinh0565/LTDNT_CHUDE02.git
   cd LTDNT_CHUDE02
   ```

2. **Cài đặt các gói phụ thuộc (Dependencies):**
   ```bash
   flutter pub get
   ```

3. **Chạy kiểm thử tự động (Unit & Widget tests):**
   ```bash
   flutter test
   ```

4. **Khởi chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

### Cách 2: Xuất và cài đặt ứng dụng bằng file APK (Android)

#### 1. Lệnh xuất file APK:
Mở terminal tại thư mục gốc của dự án và chạy lệnh sau để build:
- **Xuất bản Release (Khuyên dùng - dung lượng nhẹ, hiệu năng cao nhất):**
  ```bash
  flutter build apk --release
  ```
- **Xuất bản Debug (Dùng để kiểm thử & gỡ lỗi nhanh):**
  ```bash
  flutter build apk --debug
  ```

#### 2. Vị trí file APK sau khi xuất:
File APK xuất ra được lưu tại đường dẫn:
- Bản Release: `build/app/outputs/flutter-apk/app-release.apk`
- Bản Debug: `build/app/outputs/flutter-apk/app-debug.apk`

---

#### 3. Hướng dẫn chi tiết các cách cài đặt file APK:

##### Phương pháp 1: Cài đặt trực tiếp trên điện thoại Android (Khuyên dùng cho người dùng)
1. **Chuyển file APK vào điện thoại:**
   - Kết nối điện thoại với máy tính qua cáp USB và sao chép file `app-release.apk` vào bộ nhớ máy (thư mục *Download* hoặc thẻ nhớ).
   - Hoặc tải file APK lên Google Drive, Zalo, Telegram... rồi tải về máy điện thoại.
2. **Cho phép cài đặt từ nguồn không xác định (Unknown Sources):**
   - Khi mở file `.apk`, nếu hệ thống hiển thị thông báo *"Để bảo mật, điện thoại không được phép cài đặt các ứng dụng không xác định từ nguồn này"*:
     - Nhấn **Cài đặt (Settings)**.
     - Bật tùy chọn **Cho phép từ nguồn này (Allow from this source)**.
3. **Vượt qua cảnh báo Google Play Protect (nếu có):**
   - Do ứng dụng tự build chưa đưa lên CH Play, Google Play Protect có thể hiện cảnh báo màu đỏ/vàng: *"Ứng dụng bị chặn bởi Play Protect"* hoặc *"Không nhận dạng được nhà phát triển"*.
   - Nhấn vào **Chi tiết (More details)** -> Chọn **Vẫn cài đặt (Install anyway)**.
4. **Hoàn tất:** Nhấn **Cài đặt (Install)** -> Chờ vài giây -> Nhấn **Mở (Open)** để khởi chạy ứng dụng.

##### Phương pháp 2: Cài đặt nhanh qua ADB (Dành cho lập trình viên / máy tính kết nối điện thoại)
1. Bật **Tùy chọn cho nhà phát triển (Developer Options)** và kích hoạt **Gỡ lỗi USB (USB Debugging)** trên điện thoại Android.
2. Cắm cáp kết nối điện thoại với máy tính và chọn *"Cho phép gỡ lỗi USB"*.
3. Mở terminal tại thư mục dự án và chạy lệnh:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
   *(Tham số `-r` cho phép cài đè/cập nhật phiên bản mới mà không làm mất dữ liệu app).*

##### Phương pháp 3: Cài đặt trên máy ảo Android Emulator
- Khởi động máy ảo Android (từ Android Studio hoặc VS Code).
- **Kéo và thả (Drag & Drop)** trực tiếp file `app-release.apk` từ trình duyệt file của máy tính vào màn hình của máy ảo. Hệ thống sẽ tự động cài đặt trong tích tắc.

---

## 5. Thành viên thực hiện
- **Đinh Tiến Trung**
- **Lê Văn Nhật**
