import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Domain/stopWatch_entity.dart';
import 'stopWatch_cubit.dart';

class StopWatchPage extends StatelessWidget {
  const StopWatchPage({super.key});

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showSetTimeDialog(BuildContext context, StopWatchCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => _SetTimeDialog(
        onConfirm: (totalSeconds) => cubit.setDuration(totalSeconds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StopWatchCubit>();

    return Scaffold(
      body: SafeArea(
        child: Center(
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
                      initialData: cubit.currentValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Có lỗi khi nhận dữ liệu');
                        }

                        final seconds = snapshot.data?.remainingSeconds ?? 0;
                        final isDone = snapshot.data?.isCompleted ?? state.isCompleted;

                        return Column(
                          children: [
                            Text(
                              _formatTime(seconds),
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
                                  'HẾT GIỜ!',
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
                            label: const Text('30 giây'),
                            onPressed: state.isRunning ? null : () => cubit.setDuration(30),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.timer, size: 18),
                            label: const Text('1 phút'),
                            onPressed: state.isRunning ? null : () => cubit.setDuration(60),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.edit, size: 18),
                            label: const Text('Tự nhập...'),
                            onPressed: state.isRunning ? null : () => _showSetTimeDialog(context, cubit),
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
                          // Vô hiệu hóa khi đang chạy hoặc đã hết giờ
                          onPressed: (state.isRunning || state.isCompleted) ? null : () => cubit.start(),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Bắt đầu'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: state.isRunning ? () => cubit.pause() : null,
                          icon: const Icon(Icons.pause),
                          label: const Text('Tạm dừng'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => cubit.reset(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Đặt lại'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dialog tự nhập thời gian tách riêng StatefulWidget để dispose controller tránh memory leak
class _SetTimeDialog extends StatefulWidget {
  final void Function(int totalSeconds) onConfirm;

  const _SetTimeDialog({required this.onConfirm});

  @override
  State<_SetTimeDialog> createState() => _SetTimeDialogState();
}

class _SetTimeDialogState extends State<_SetTimeDialog> {
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(text: '0');
    _minutesController = TextEditingController(text: '1');
    _secondsController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _submit() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    if (totalSeconds > 0) {
      widget.onConfirm(totalSeconds);
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = 'Vui lòng nhập thời gian lớn hơn 0 giây!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.timer_outlined, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text('Cài đặt thời gian đếm ngược'),
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
                    controller: _hoursController,
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
                    controller: _minutesController,
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
                    controller: _secondsController,
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}
