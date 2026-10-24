import 'stopWatch_entity.dart';
import 'stopWatch_repository.dart';

class StopWatchUseCase {
  final StopWatchRepository repository;

  StopWatchUseCase(this.repository);

  Stream<StopWatchEntity> get stream => repository.stream;

  StopWatchEntity get currentValue => repository.currentValue;

  Future<StopWatchEntity> getInitialValue() {
    return repository.getInitialValue();
  }

  void setDuration(int seconds) {
    repository.setDuration(seconds);
  }

  void start() {
    repository.start();
  }

  void pause() {
    repository.pause();
  }

  void reset() {
    repository.reset();
  }

  Future<void> dispose() {
    return repository.dispose();
  }
}
