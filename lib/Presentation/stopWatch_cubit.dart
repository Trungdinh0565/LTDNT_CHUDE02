import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Domain/stopWatch_entity.dart';
import '../Domain/stopWatch_usecase.dart';

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
}

class StopWatchCubit extends Cubit<StopWatchState> {
  final StopWatchUseCase useCase;
  StreamSubscription<StopWatchEntity>? _streamSubscription;

  StopWatchCubit(this.useCase) : super(const StopWatchState());

  Stream<StopWatchEntity> get timeStream => useCase.stream;

  StopWatchEntity get currentValue => useCase.currentValue;

  Future<void> initialize() async {
    try {
      await useCase.getInitialValue();
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }

    _streamSubscription?.cancel();
    _streamSubscription = useCase.stream.listen((entity) {
      if (!isClosed && entity.isCompleted) {
        emit(state.copyWith(isRunning: false, isCompleted: true));
      }
    });
  }

  void setDuration(int seconds) {
    if (isClosed) return;
    useCase.setDuration(seconds);
    emit(state.copyWith(isRunning: false, isCompleted: false));
  }

  void start() {
    // Không cho phép bấm chạy khi đang chạy hoặc đã đếm xong về 0
    if (isClosed || state.isRunning || state.isCompleted) return;

    useCase.start();
    emit(state.copyWith(isLoading: false, isRunning: true, isCompleted: false));
  }

  void pause() {
    if (isClosed || !state.isRunning) return;

    useCase.pause();
    emit(state.copyWith(isRunning: false));
  }

  void reset() {
    if (isClosed) return;

    useCase.reset();
    emit(state.copyWith(isLoading: false, isRunning: false, isCompleted: false));
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    await useCase.dispose();
    await super.close();
  }
}
