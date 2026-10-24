import '../Domain/stopWatch_entity.dart';

class StopWatchModel extends StopWatchEntity {
  const StopWatchModel({
    required super.remainingSeconds,
    super.initialSeconds = 0,
    super.isCompleted = false,
  });
}
