import 'package:flutter_test/flutter_test.dart';
import 'package:ltdnt_chude02/injection_container.dart';
import 'package:ltdnt_chude02/main.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await setupDependencies();
  });

  testWidgets('StopWatch UI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ĐỒNG HỒ BẤM GIỜ'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
