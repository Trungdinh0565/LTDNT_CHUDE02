import 'package:flutter_bloc/flutter_bloc.dart';

import '../Domain/stopWatch_usecase.dart';

class StopWatchState {
  final bool isLoading;
  final bool isRunning;

  const StopWatchState({
    this.isLoading = true,
    this.isRunning = false,
  });
}

class StopWatchCubit extends Cubit<StopWatchState> {
  final StopWatchUseCase useCase;

  StopWatchCubit(this.useCase) : super(const StopWatchState());

  get stream => useCase.stream;

  Future<void> initialize() async {
    try {
      await useCase.getInitialValue();

      if (!isClosed) {
        emit(const StopWatchState(isLoading: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(const StopWatchState(isLoading: false));
      }
    }
  }

  void start() {
    if (isClosed || state.isRunning) return;

    useCase.start();

    emit(
      StopWatchState(
        isLoading: false,
        isRunning: true,
      ),
    );
  }

  void pause() {
    if (isClosed || !state.isRunning) return;

    useCase.pause();

    emit(
      const StopWatchState(
        isLoading: false,
        isRunning: false,
      ),
    );
  }

  void reset() {
    if (isClosed) return;

    useCase.reset();

    emit(
      const StopWatchState(
        isLoading: false,
        isRunning: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await useCase.dispose();
    await super.close();
  }
}