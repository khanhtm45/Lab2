import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_preferences.dart';
import 'app_strings.dart';

extension AppStringsContext on BuildContext {
  AppStrings get strings => AppStrings(watch<AppPreferences>().language);
}

extension AppStringsRead on BuildContext {
  AppStrings get stringsOf => AppStrings(read<AppPreferences>().language);
}
