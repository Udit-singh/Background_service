import 'package:flutter/cupertino.dart';

import 'usage_service.dart';

void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();

  Service.instance().getUsageStats();
}
