import 'package:flutter/foundation.dart';

void log(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}
