import 'dart:developer' as developer;

/// Simple logger utility to replace print statements
/// Uses dart:developer log which is production-safe
class Logger {
  final String name;

  const Logger(this.name);

  void debug(String message) {
    developer.log(message, name: name, level: 500);
  }

  void info(String message) {
    developer.log(message, name: name, level: 800);
  }

  void warning(String message) {
    developer.log(message, name: name, level: 900);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
