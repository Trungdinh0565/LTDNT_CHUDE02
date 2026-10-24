import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Domain/stopWatch_entity.dart';
import '../Domain/stopWatch_usecase.dart';

/// Trạng thái của StopWatchCubit quản lý giao diện
class StopWatchState {
  final bool isLoading;
  final bool isRunning;
  final bool isCompleted;

  const StopWatchState({
    this.isLoading = true,
    this.isRunning = false,
    this.isCompleted = false,
  });

  StopWatchState copyWith({
    bool? isLoading,
    bool? isRunning,
    bool? isCompleted,
  }) =>
      StopWatchState(
        isLoading: isLoading ?? this.isLoading,
        isRunning: isRunning ?? this.isRunning,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopWatchState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isRunning == other.isRunning &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(isLoading, isRunning, isCompleted);

  @override
  String toString() =>
      'StopWatchState(isLoading: $isLoading, isRunning: $isRunning, isCompleted: $isCompleted)';
}

/// Cubit điều khiển trạng thái đồng hồ đếm ngược trong tầng Presentation,
/// tương tác trực tiếp với StopWatchUseCase ở tầng Domain.
class StopWatchCubit extends Cubit<StopWatchState> {
  final StopWatchUseCase useCase;
  StreamSubscription<StopWatchEntity>? _streamSubscription;

  StopWatchCubit(this.useCase) : super(const StopWatchState());

  /// Luồng dữ liệu thời gian phát ra từ Repository qua UseCase
  Stream<StopWatchEntity> get timeStream => useCase.stream;

  /// Giá trị thời gian hiện tại
  StopWatchEntity get currentValue => useCase.currentValue;

  /// Khởi tạo dữ liệu ban đầu bất đồng bộ và thiết lập lắng nghe stream
  Future<void> initialize() async {
    _streamSubscription?.cancel();
    _streamSubscription = useCase.stream.listen((entity) {
      if (!isClosed && entity.isCompleted) {
        emit(state.copyWith(isRunning: false, isCompleted: true));
      }
    });

    try {
      final initialEntity = await useCase.getInitialValue();
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isCompleted: initialEntity.isCompleted,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  /// Cài đặt khoảng thời gian đếm ngược (tính bằng giây)
  void setDuration(int seconds) {
    if (isClosed) return;

    useCase.setDuration(seconds);
    emit(
      state.copyWith(
        isLoading: false,
        isRunning: false,
        isCompleted: seconds <= 0,
      ),
    );
  }

  /// Bắt đầu đếm ngược
  void start() {
    // Không cho phép bắt đầu khi đang chạy, đã hoàn thành hoặc thời gian còn lại <= 0
    if (isClosed ||
        state.isRunning ||
        state.isCompleted ||
        currentValue.remainingSeconds <= 0) {
      return;
    }

    useCase.start();
    emit(state.copyWith(isLoading: false, isRunning: true, isCompleted: false));
  }

  /// Tạm dừng đếm ngược
  void pause() {
    if (isClosed || !state.isRunning) return;

    useCase.pause();
    emit(state.copyWith(isRunning: false));
  }

  /// Đặt lại về thời gian ban đầu
  void reset() {
    if (isClosed) return;

    useCase.reset();
    emit(
      state.copyWith(
        isLoading: false,
        isRunning: false,
        isCompleted: currentValue.initialSeconds <= 0,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    await useCase.dispose();
    await super.close();
  }
}
