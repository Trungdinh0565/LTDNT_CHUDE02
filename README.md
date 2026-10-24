# LTDNT_CHUDE02 - Quản lý Bất đồng bộ với Future & Stream trong Flutter
*Báo cáo tuần - Chủ đề 02: Quản lý Bất đồng bộ (Asynchronous Programming) trong Flutter*

---

## 1. Giới thiệu tổng quan
Dự án **Countdown Timer App** (Đồng hồ đếm ngược) được xây dựng phục vụ môn học **Lập trình đa nền tảng - Chủ đề 02**.  
Ứng dụng minh họa trực quan và toàn diện cách áp dụng các cơ chế xử lý bất đồng bộ cốt lõi trong Flutter và Dart, kết hợp với kiến trúc **Clean Architecture** và mô hình quản lý trạng thái **BLoC/Cubit**:

- **Future & async/await:** Giả lập tác vụ bất đồng bộ khởi tạo dữ liệu ban đầu (`getInitialValue()`).
- **StreamController & Timer:** Phát luồng dữ liệu thời gian thực định kỳ mỗi giây (`stream`), đếm ngược an toàn về 0 và thông báo hoàn thành.
- **StreamBuilder & BlocBuilder:** Tự động lắng nghe và cập nhật giao diện người dùng theo thời gian thực (real-time UI updates) mà không gây giật lag hay render thừa.
- **Clean Architecture & Dependency Injection:** Phân tách rõ ràng các tầng Domain, Data, Presentation và quản lý phụ thuộc linh hoạt thông qua `get_it`.

---

## 2. Tính năng nổi bật
- ⏱️ **Đồng hồ đếm ngược trực quan:** Hiển thị thời gian dạng chuẩn `HH:MM:SS` kèm vòng tròn tiến trình (Circular Progress Indicator) thể hiện tỷ lệ phần trăm thời gian còn lại.
- ⚡ **Thiết lập thời gian nhanh (Presets):** Cung cấp các nút chọn nhanh: 1 phút, 3 phút, 5 phút, 10 phút.
- ✏️ **Tự nhập thời gian:** Dialog cho phép người dùng tùy chỉnh số Giờ, Phút, Giây tùy ý.
- ⏯️ **Điều khiển linh hoạt:** Bắt đầu (Start), Tạm dừng (Pause), Đặt lại về thời gian ban đầu (Reset).
- 🔔 **Thông báo trạng thái hoàn thành:** Tự động phát hiện khi hết giờ (`isCompleted = true`), hủy Timer và hiển thị nhãn `⏰ HẾT GIỜ!`.
- 🧪 **Kiểm thử tự động (Widget & Unit Tests):** Bộ test toàn diện kiểm tra đầy đủ vòng đời đếm ngược, chuyển đổi preset, mở dialog nhập số và xử lý luồng bất đồng bộ.

---

## 3. Công nghệ và Thư viện sử dụng
- **Flutter SDK** (hỗ trợ đa nền tảng: Android, iOS, Web, Windows, macOS, Linux).
- **Dart Async (`Future`, `Stream`, `StreamController.broadcast()`, `Timer`):** Xử lý tác vụ bất đồng bộ và luồng dữ liệu thời gian.
- **Clean Architecture:** Tách biệt rõ ràng giữa Business Logic, Data và UI.
- **flutter_bloc (`Cubit` & `BlocBuilder`):** Quản lý trạng thái giao diện (`isLoading`, `isRunning`).
- **get_it:** Service Locator / Dependency Injection giúp giải phóng phụ thuộc giữa các lớp.

---

## 4. Cấu trúc thư mục dự án
Dự án được tổ chức theo cấu trúc Clean Architecture chuẩn hóa:

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
│   ├── stopWatch_cubit.dart      # Quản lý trạng thái chạy/dừng (StopWatchCubit & StopWatchState)
│   └── stopWatch_page.dart       # Giao diện đếm ngược (StreamBuilder + BlocBuilder)
├── injection_container.dart       # Cấu hình Dependency Injection (GetIt)
└── main.dart                     # Điểm khởi chạy ứng dụng (main entry point)
test/
└── widget_test.dart              # Kiểm thử giao diện và kịch bản bất đồng bộ
```

---

## 5. Chi tiết kiến trúc và luồng dữ liệu bất đồng bộ

### 5.1. Domain Layer (Lớp nghiệp vụ)
- **`StopWatchEntity`**: Chứa dữ liệu cốt lõi:
  - `remainingSeconds`: Số giây còn lại.
  - `initialSeconds`: Thời gian ban đầu được thiết lập.
  - `isCompleted`: Cờ đánh dấu khi đồng hồ đếm về 0.
- **`StopWatchRepository`**: Interface định nghĩa:
  - `Stream<StopWatchEntity> get stream;`
  - `Future<StopWatchEntity> getInitialValue();`
  - `void start();`
  - `void pause();`
  - `void reset();`
  - `void setDuration(int seconds);`
  - `Future<void> dispose();`
- **`StopWatchUseCase`**: Lớp trung gian chuyển tiếp và xử lý các ca nghiệp vụ từ Cubit xuống Repository.

### 5.2. Data Layer (Lớp dữ liệu & Xử lý bất đồng bộ)
- **`StopWatchModel`**: Kế thừa `StopWatchEntity`.
- **`StopWatchRepositoryImpl`**:
  - Quản lý `StreamController<StopWatchEntity>.broadcast()` để nhiều widget/listener có thể lắng nghe luồng dữ liệu cùng lúc.
  - **`getInitialValue()`**: Sử dụng `Future.delayed(Duration(milliseconds: 500))` mô phỏng quá trình khởi tạo dữ liệu bất đồng bộ trước khi hiển thị.
  - **`start()`**: Sử dụng `Timer.periodic(Duration(seconds: 1))` trừ lùi `_remainingSeconds` mỗi giây, gửi đối tượng `StopWatchModel` mới nhất vào stream qua `_controller.add()`. Khi thời gian về 0, Timer tự động dừng và gửi sự kiện hoàn tất.
  - **`pause()`**: Hủy instance `Timer` hiện tại nhưng vẫn giữ nguyên giá trị `_remainingSeconds`.
  - **`reset()`**: Khôi phục `_remainingSeconds` về bằng `_initialSeconds` và đẩy dữ liệu mới vào stream.
  - **`setDuration(int seconds)`**: Cho phép thay đổi mốc thời gian đếm ngược mới và phát dữ liệu ngay lập tức.
  - **`dispose()`**: Đóng stream controller và hủy Timer khi giải phóng tài nguyên.

### 5.3. Presentation Layer (Lớp giao diện & Quản lý trạng thái)
- **`StopWatchCubit`**: Phát ra `StopWatchState` quản lý 2 cờ: `isLoading` (đang nạp dữ liệu ban đầu) và `isRunning` (đồng hồ đang chạy hay tạm dừng).
- **`StopWatchPage`**:
  - `BlocBuilder<StopWatchCubit, StopWatchState>`: Kiểm soát trạng thái hiển thị loading spinner hoặc bật/tắt (enable/disable) các nút điều khiển phù hợp.
  - `StreamBuilder<StopWatchEntity>`: Lắng nghe trực tiếp `cubit.stream` để vẽ lại đồng hồ số, vòng đếm ngược CircularProgressIndicator và huy hiệu thông báo (status badge) theo thời gian thực mà không cần `setState()` thủ công.

### 5.4. Dependency Injection
Được cấu hình tập trung trong [injection_container.dart](file:///D:/DNTCDE2/lib/injection_container.dart) sử dụng `GetIt`:
- `StopWatchRepository` -> `StopWatchRepositoryImpl` (Factory)
- `StopWatchUseCase` -> `StopWatchUseCase` (Factory)
- `StopWatchCubit` -> `StopWatchCubit` (Factory)

---

## 6. Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu môi trường
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `>=3.13.0`).
- Dart SDK tương ứng đi kèm Flutter.
- Trình biên dịch: Visual Studio Code, Android Studio hoặc Cursor.

### Các bước thực hiện
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

## 7. Thành viên thực hiện
- **Đinh Tiến Trung**
- **Lê Văn Nhật**
