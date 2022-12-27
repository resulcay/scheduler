import 'package:flutter/material.dart';
import 'media_query_extension.dart';

extension PaddingExtension on BuildContext {
  EdgeInsets get paddingLow => EdgeInsets.all(height * 0.01);
  EdgeInsets get paddingNormal => EdgeInsets.all(height * 0.02);
  EdgeInsets get paddingLarge => EdgeInsets.all(height * 0.04);
  EdgeInsets get paddingLarger => EdgeInsets.all(height * 0.08);
}
