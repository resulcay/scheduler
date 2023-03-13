// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:scheduler/services/path_service.dart';

class LocaleConstant extends PathService {
  static const trLocale = Locale('tr', 'TR');
  static const engLocale = Locale('en', 'US');
  static const TRANSLATION_PATH = 'assets/translations';
}
