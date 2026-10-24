import 'dart:ui';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StopWatchCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Future & Stream'),
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

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'ĐỒNG HỒ BẤM GIỜ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<StopWatchEntity>(
                  stream: cubit.stream,
                  initialData: const StopWatchEntity(
                    elapsedSeconds: 0,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Có lỗi khi nhận dữ liệu');
                    }

                    final seconds =
                        snapshot.data?.elapsedSeconds ?? 0;

                    return Text(
                      formatTime(seconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  state.isRunning ? 'Đang chạy' : 'Đang tạm dừng',
                  style: TextStyle(
                    fontSize: 16,
                    color: state.isRunning ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 36),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.isRunning
                          ? null
                          : () => cubit.start(),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Bắt đầu'),
                    ),
                    ElevatedButton.icon(
                      onPressed: state.isRunning
                          ? () => cubit.pause()
                          : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Tạm dừng'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => cubit.reset(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Đặt lại'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Future/async-await: khởi tạo dữ liệu\n'
                    'StreamController: phát thời gian mỗi giây\n'
                    'StreamBuilder: cập nhật giao diện tự động',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}