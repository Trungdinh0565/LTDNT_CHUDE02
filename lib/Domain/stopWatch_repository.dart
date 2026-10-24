import 'stopWatch_entity.dart';

abstract class StopWatchRepository {
  Stream<StopWatchEntity> get stream;

  StopWatchEntity get currentValue;

  Future<StopWatchEntity> getInitialValue();

  void setDuration(int seconds);

  void start();

  void pause();

  void reset();

  Future<void> dispose();
}
