
import 'dart:async';

import '../Domain/stopWatch_entity.dart';
import '../Domain/stopWatch_repository.dart';
import 'stopWatch_model.dart';

class StopWatchRepositoryImpl implements StopWatchRepository {
  final StreamController<StopWatchEntity> _controller =
      StreamController<StopWatchEntity>();

  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isDisposed = false;

  @override
  Stream<StopWatchEntity> get stream => _controller.stream;

  @override
  Future<StopWatchEntity> getInitialValue() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const StopWatchModel(elapsedSeconds: 0);
  }

  @override
  void start() {
    if (_isDisposed || _timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || _controller.isClosed) return;

      _elapsedSeconds++;

      _controller.add(
        StopWatchModel(elapsedSeconds: _elapsedSeconds),
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
    _elapsedSeconds = 0;

    if (!_controller.isClosed) {
      _controller.add(
        const StopWatchModel(elapsedSeconds: 0),
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
