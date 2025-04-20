import 'dart:async';

class BookingTimerService {
  static const int _timerDuration = 600; // 5 minutes in seconds

  // Singleton pattern
  static final BookingTimerService _instance = BookingTimerService._internal();
  factory BookingTimerService() => _instance;
  BookingTimerService._internal();

  Timer? _timer;
  int _secondsRemaining = _timerDuration;
  Function? _onTimeExpired;
  final List<Function(int)> _listeners = [];

  bool get isRunning => _timer != null && _timer!.isActive;
  int get secondsRemaining => _secondsRemaining;

  // Format time as mm:ss
  String get timeRemainingFormatted {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void resetTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    // Reset seconds remaining to initial value (5 minutes = 300 seconds)
    _secondsRemaining = 300;
    _notifyListeners();
  }

  // Start the timer
  void startTimer({Function? onTimeExpired}) {
    // Cancel any existing timer
    stopTimer();

    // Reset timer
    _secondsRemaining = _timerDuration;
    _onTimeExpired = onTimeExpired;

    // Start a new timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        _notifyListeners();
      } else {
        stopTimer();
        if (_onTimeExpired != null) {
          _onTimeExpired!();
        }
      }
    });
  }

  // Stop the timer
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  // Add a listener that will be called when the timer updates
  void addListener(Function(int) listener) {
    _listeners.add(listener);
  }

  // Remove a listener
  void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_secondsRemaining);
    }
  }

  // Dispose
  void dispose() {
    stopTimer();
    _listeners.clear();
  }
}
