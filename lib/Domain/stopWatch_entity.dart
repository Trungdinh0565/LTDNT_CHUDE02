class StopWatchEntity {
  final int remainingSeconds;
  final int initialSeconds;
  final bool isCompleted;

  const StopWatchEntity({
    required this.remainingSeconds,
    this.initialSeconds = 0,
    this.isCompleted = false,
  });

  // Tương thích ngược nếu có nơi sử dụng elapsedSeconds
  int get elapsedSeconds => remainingSeconds;
}
