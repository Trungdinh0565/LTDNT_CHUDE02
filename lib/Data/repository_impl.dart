import 'dart:async';

import '../Domain/stopWatch_entity.dart';
import '../Domain/stopWatch_repository.dart';
import 'stopWatch_model.dart';

class StopWatchRepositoryImpl implements StopWatchRepository {
  final StreamController<StopWatchEntity> _controller =
      StreamController<StopWatchEntity>.broadcast();

  Timer? _timer;
  int _initialSeconds = 60; // Mặc định ban đầu 60 giây (1 phút)
  int _remainingSeconds = 60;
  bool _isDisposed = false;

  @override
  Stream<StopWatchEntity> get stream => _controller.stream;

  @override
  Future<StopWatchEntity> getInitialValue() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return StopWatchModel(
      remainingSeconds: _remainingSeconds,
      initialSeconds: _initialSeconds,
      isCompleted: false,
    );
  }

  @override
  void setDuration(int seconds) {
    if (_isDisposed) return;

    pause();
    _initialSeconds = seconds > 0 ? seconds : 0;
    _remainingSeconds = _initialSeconds;

    if (!_controller.isClosed) {
      _controller.add(
        StopWatchModel(
          remainingSeconds: _remainingSeconds,
          initialSeconds: _initialSeconds,
          isCompleted: false,
        ),
      );
    }
  }

  @override
  void start() {
    if (_isDisposed || _timer != null || _remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || _controller.isClosed) return;

      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      }

      final isCompleted = _remainingSeconds == 0;
      if (isCompleted) {
        _timer?.cancel();
        _timer = null;
      }

      _controller.add(
        StopWatchModel(
          remainingSeconds: _remainingSeconds,
          initialSeconds: _initialSeconds,
          isCompleted: isCompleted,
        ),
      );
    });
  }

  @override
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void reset() {
    if (_isDisposed) return;

    pause();
    _remainingSeconds = _initialSeconds;

    if (!_controller.isClosed) {
      _controller.add(
        StopWatchModel(
          remainingSeconds: _remainingSeconds,
          initialSeconds: _initialSeconds,
          isCompleted: false,
        ),
      );
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _timer?.cancel();
    _timer = null;

    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
