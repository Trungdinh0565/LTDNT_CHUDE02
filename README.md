# LTDNT_CHUDE02 - Quản lý Bất đồng bộ với Future & Stream trong Flutter
*Báo cáo tuần - chủ đề 02*
## 1. Giới thiệu
Dự án **StopWatch App** (Đồng hồ bấm giờ) được xây dựng phục vụ môn học **Lập trình đa nền tảng - Chủ đề 02**.  
Ứng dụng minh họa trực quan cách áp dụng các cơ chế xử lý bất đồng bộ cốt lõi trong Flutter và Dart kết hợp với kiến trúc Clean Architecture:
- **Future & async/await:** Khởi tạo dữ liệu ban đầu bất đồng bộ (`getInitialValue()`).
- **StreamController & Timer:** Phát luồng dữ liệu thời gian thực định kỳ mỗi giây (`stream`).
- **StreamBuilder & BlocBuilder:** Tự động lắng nghe và cập nhật giao diện người dùng theo thời gian thực mà không làm ảnh hưởng đến hiệu năng hiển thị.
- **Clean Architecture & Dependency Injection:** Phân tách rõ ràng các tầng Domain, Data, Presentation và quản lý phụ thuộc bằng `get_it`.

---

## 2. Công nghệ và Thư viện sử dụng
- **Flutter & Dart SDK** (hỗ trợ đa nền tảng: Android, iOS, Web, Windows, macOS, Linux).
- **Clean Architecture:** Tách biệt rõ ràng giữa Business Logic, Data và UI.
- **flutter_bloc (Cubit):** Quản lý trạng thái giao diện (`StopWatchCubit` & `StopWatchState`).
- **get_it:** Service Locator / Dependency Injection giúp tách rời sự phụ thuộc giữa các lớp.
- **Dart Async (Future, Stream, StreamController, Timer):** Xử lý luồng dữ liệu bất đồng bộ.

---

## 3. Cấu trúc dự án
Dự án được tổ chức theo mô hình Clean Architecture:

```text
lib/
├── Data/
│   ├── repository_impl.dart      # Triển khai StopWatchRepository với Timer và StreamController
│   └── stopWatch_model.dart      # Model kế thừa từ StopWatchEntity
├── Domain/
│   ├── stopWatch_entity.dart     # Thực thể biểu diễn dữ liệu thời gian (elapsedSeconds)
│   ├── stopWatch_repository.dart # Interface định nghĩa các phương thức nghiệp vụ
│   └── stopWatch_usecase.dart    # Ca sử dụng (start, pause, reset, stream)
├── Presentation/
│   ├── stopWatch_cubit.dart      # Quản lý trạng thái chạy/tạm dừng và khởi tạo
│   └── stopWatch_page.dart       # Giao diện đồng hồ bấm giờ (StreamBuilder + BlocBuilder)
├── injection_container.dart       # Cấu hình Dependency Injection (GetIt)
└── main.dart                     # Điểm khởi chạy ứng dụng
```

---

## 4. Chi tiết kiến trúc và luồng dữ liệu

### 4.1. Domain Layer (Lớp nghiệp vụ)
- **`StopWatchEntity`**: Chứa thuộc tính `elapsedSeconds` (số giây đã trôi qua).
- **`StopWatchRepository`**: Hợp đồng trừu tượng (abstract class) định nghĩa:
  - `Stream<StopWatchEntity> get stream;`
  - `Future<StopWatchEntity> getInitialValue();`
  - `void start();`
  - `void pause();`
  - `void reset();`
  - `Future<void> dispose();`
- **`StopWatchUseCase`**: Lớp trung gian tiếp nhận yêu cầu từ Presentation và chuyển tiếp đến Repository.

### 4.2. Data Layer (Lớp dữ liệu)
- **`StopWatchModel`**: Kế thừa `StopWatchEntity`.
- **`StopWatchRepositoryImpl`**:
  - Khởi tạo `StreamController<StopWatchEntity>` để phát luồng dữ liệu thời gian.
  - Sử dụng `Timer.periodic(Duration(seconds: 1))` khi bắt đầu chạy (`start`) để cộng dồn giây và gửi dữ liệu qua `StreamController.add()`.
  - Giả lập khởi tạo bất đồng bộ với `Future.delayed` trong `getInitialValue()`.
  - Quản lý đóng Stream và hủy Timer an toàn trong `dispose()`.

### 4.3. Presentation Layer (Lớp giao diện & Quản lý trạng thái)
- **`StopWatchCubit`**: Quản lý trạng thái ứng dụng (`isLoading`, `isRunning`). Gọi các hàm tương ứng từ UseCase.
- **`StopWatchPage`**: 
  - `BlocBuilder`: Theo dõi trạng thái để hiển thị màn hình chờ tải hoặc trạng thái hoạt động của các nút bấm.
  - `StreamBuilder`: Lắng nghe trực tiếp `cubit.stream` để cập nhật đồng hồ (HH:MM:SS) theo thời gian thực mỗi giây.
  - Cung cấp các nút điều khiển: **Bắt đầu (Start)**, **Tạm dừng (Pause)**, và **Đặt lại (Reset)**.

### 4.4. Dependency Injection
Được cấu hình trong `injection_container.dart` sử dụng `get_it`:
- Đăng ký Factory cho `StopWatchRepository` -> `StopWatchRepositoryImpl`
- Đăng ký Factory cho `StopWatchUseCase` -> `StopWatchUseCase`
- Đăng ký Factory cho `StopWatchCubit` -> `StopWatchCubit`

---

## 5. Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu môi trường
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `>=3.13.0`).
- Trình biên dịch: Visual Studio Code hoặc Android Studio.

### Các bước thực hiện
1. **Clone repository:**
   ```bash
   git clone https://github.com/Trungdinh0565/LTDNT_CHUDE02.git
   cd LTDNT_CHUDE02
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

---

## 6. Thành viên thực hiện
- **Đinh Tiến Trung**
- **Lê Văn Nhật**

---
