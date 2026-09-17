class DurationFormatter {
  /// Converts seconds integer to string formatted as MM:SS or HH:MM:SS
  static String formatSeconds(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hoursStr = hours.toString().padLeft(2, '0');
      return '$hoursStr:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }
}
