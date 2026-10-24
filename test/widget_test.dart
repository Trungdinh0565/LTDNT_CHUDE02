import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ltdnt_chude02/injection_container.dart';
import 'package:ltdnt_chude02/main.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await setupDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('StopWatch UI smoke test and countdown logic', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ĐỒNG HỒ ĐẾM NGƯỢC'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
    expect(find.text('00:01:00'), findsOneWidget);

    // Test chọn preset 3 phút từ UI
    await tester.tap(find.text('3 phút'));
    await tester.pumpAndSettle();
    expect(find.text('00:03:00'), findsOneWidget);

    // Test mở dialog tự nhập thời gian
    await tester.tap(find.text('Tự nhập...'));
    await tester.pumpAndSettle();

    expect(find.text('Cài đặt thời gian đếm ngược'), findsOneWidget);

    // Nhập 0 giờ, 0 phút, 5 giây
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '0'); // Giờ
    await tester.enterText(textFields.at(1), '0'); // Phút
    await tester.enterText(textFields.at(2), '3'); // Giây
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();

    expect(find.text('00:00:03'), findsOneWidget);

    // Nhấn Bắt đầu
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(find.text('Đang đếm ngược...'), findsOneWidget);

    // 1 giây sau -> còn 00:00:02
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:00:02'), findsOneWidget);

    // Nhấn Tạm dừng
    await tester.tap(find.text('Tạm dừng'));
    await tester.pump();
    expect(find.text('Đang tạm dừng / Chờ bắt đầu'), findsOneWidget);

    // Nhấn Bắt đầu tiếp
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();

    // 1 giây sau -> còn 00:00:01
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:00:01'), findsOneWidget);

    // 1 giây sau -> còn 00:00:00 và hoàn thành
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('⏰ HẾT GIỜ!'), findsOneWidget);
    expect(find.text('Đã hoàn thành đếm ngược'), findsOneWidget);

    // Kiểm tra nút Bắt đầu bị vô hiệu hóa khi hết giờ
    final startButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Bắt đầu'),
    );
    expect(startButton.onPressed, isNull);

    // Nhấn Đặt lại -> quay về 00:00:03
    await tester.tap(find.text('Đặt lại'));
    await tester.pumpAndSettle();
    expect(find.text('00:00:03'), findsOneWidget);
    expect(find.text('Đang tạm dừng / Chờ bắt đầu'), findsOneWidget);
  });
}
