import 'package:flutter/foundation.dart';

mixin ResponsiveMixin {
  int get crossAxisCountGridView {
    return kIsWeb ? 10 : 1;
  }
}
