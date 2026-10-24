import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Domain/stopWatch_entity.dart';
import 'stopWatch_cubit.dart';

class StopWatchPage extends StatelessWidget {
  const StopWatchPage({super.key});

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSetTimeDialog(BuildContext context, StopWatchCubit cubit) {
    final hoursController = TextEditingController(text: '0');
    final minutesController = TextEditingController(text: '1');
    final secondsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cài đặt thời gian đếm ngược',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nhập thời gian bạn muốn đếm ngược:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Giờ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Phút',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: secondsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Giây',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final hours = int.tryParse(hoursController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;
                final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

                if (totalSeconds > 0) {
                  cubit.setDuration(totalSeconds);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập thời gian lớn hơn 0 giây!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StopWatchCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Future & Stream Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: BlocBuilder<StopWatchCubit, StopWatchState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo dữ liệu bất đồng bộ...'),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.isCompleted
                        ? Icons.alarm_on_rounded
                        : Icons.hourglass_bottom_rounded,
                    size: 80,
                    color: state.isCompleted
                        ? Colors.red
                        : (state.isRunning ? Colors.blue : Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ĐỒNG HỒ ĐẾM NGƯỢC',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<StopWatchEntity>(
                    stream: cubit.timeStream,
                    initialData: const StopWatchEntity(
                      remainingSeconds: 60,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Có lỗi khi nhận dữ liệu');
                      }

                      final seconds = snapshot.data?.remainingSeconds ?? 0;
                      final isDone = snapshot.data?.isCompleted ?? false;

                      return Column(
                        children: [
                          Text(
                            formatTime(seconds),
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: isDone ? Colors.red : Colors.blue.shade900,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (isDone)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                '⏰ HẾT GIỜ!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.isRunning
                        ? 'Đang đếm ngược...'
                        : (state.isCompleted
                            ? 'Đã hoàn thành đếm ngược'
                            : 'Đang tạm dừng / Chờ bắt đầu'),
                    style: TextStyle(
                      fontSize: 16,
                      color: state.isRunning
                          ? Colors.green
                          : (state.isCompleted ? Colors.red : Colors.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bộ chọn nhanh thời gian
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.timer, size: 18),
                          label: const Text('1 phút'),
                          onPressed: state.isRunning
                              ? null
                              : () => cubit.setDuration(60),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.timer, size: 18),
                          label: const Text('3 phút'),
                          onPressed: state.isRunning
                              ? null
                              : () => cubit.setDuration(180),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.timer, size: 18),
                          label: const Text('5 phút'),
                          onPressed: state.isRunning
                              ? null
                              : () => cubit.setDuration(300),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.timer, size: 18),
                          label: const Text('10 phút'),
                          onPressed: state.isRunning
                              ? null
                              : () => cubit.setDuration(600),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.edit, size: 18),
                          label: const Text('Tự nhập...'),
                          onPressed: state.isRunning
                              ? null
                              : () => _showSetTimeDialog(context, cubit),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Các nút điều khiển chính
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isRunning ? null : () => cubit.start(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Bắt đầu'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isRunning ? () => cubit.pause() : null,
                        icon: const Icon(Icons.pause),
                        label: const Text('Tạm dừng'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => cubit.reset(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Đặt lại'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '• Future/async-await: Khởi tạo giá trị thời gian ban đầu\n'
                      '• StreamController & Timer: Đếm ngược mỗi giây về 0\n'
                      '• StreamBuilder & Cubit: Cập nhật giao diện và trạng thái tự động',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
