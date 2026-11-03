import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_colors.dart';

/// Vector redraw of the launcher icon (orange-to-pink clipboard with clock),
/// so store/App Store icons are sharp at any size.
class AppIconPainter extends CustomPainter {
  const AppIconPainter({this.background = Colors.white});

  final Color background;

  static const top = Color(0xFFFFC46B);
  static const bottom = Color(0xFFFF5C8A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 1024);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1024, 1024),
      Paint()..color = background,
    );
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top, bottom],
    ).createShader(const Rect.fromLTWH(0, 120, 1024, 800));
    Paint stroke(double w) => Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = background;

    // Board and paper.
    canvas.drawRRect(
      RRect.fromLTRBR(240, 200, 730, 870, const Radius.circular(64)),
      stroke(30),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(300, 270, 670, 810, const Radius.circular(22)),
      stroke(20),
    );
    // Clip.
    final clip = RRect.fromLTRBR(425, 130, 545, 300, const Radius.circular(60));
    canvas.drawRRect(clip, fill);
    canvas.drawRRect(clip, stroke(26));
    // Header block and text lines.
    canvas.drawRect(
      const Rect.fromLTRB(365, 360, 605, 430),
      Paint()
        ..shader = shader
        ..color = Colors.white.withValues(alpha: .4),
    );
    for (final (y, w) in [
      (500.0, 240.0),
      (565.0, 200.0),
      (630.0, 160.0),
      (695.0, 120.0),
    ]) {
      canvas.drawLine(Offset(375, y), Offset(375 + w, y), stroke(24));
    }
    // Clock.
    const c = Offset(710, 745);
    canvas.drawCircle(c, 165, fill);
    canvas.drawCircle(c, 150, stroke(30));
    canvas.drawLine(c, c.translate(0, -85), stroke(24));
    canvas.drawLine(c, c.translate(75, 0), stroke(24));
    canvas.drawCircle(c, 20, fill);
    canvas.drawCircle(c, 20, stroke(14));
  }

  @override
  bool shouldRepaint(covariant AppIconPainter old) =>
      old.background != background;
}

/// Brand gradients for screenshot backgrounds, cycled per screen.
const backgrounds = [
  [ConstantColor.deepTeal, Color(0xFF1B4F4F)],
  [ConstantColor.normalOrange, Color(0xFFE0603A)],
  [Color(0xFF3D5AFE), Color(0xFF283593)],
  [Color(0xFF8E24AA), Color(0xFF4A148C)],
  [ConstantColor.elegantBlack, ConstantColor.darkBlack],
  [Color(0xFF00897B), ConstantColor.deepTeal],
];

/// Encodes RGBA pixels as an opaque 24-bit PNG (stores reject alpha in
/// screenshots and the App Store icon).
Uint8List encodeRgbPng(ByteData rgba, int width, int height) {
  final raw = BytesBuilder(copy: false);
  final row = Uint8List(1 + width * 3);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      final a = rgba.getUint8(i + 3) / 255;
      // Composite on white in case anything is translucent.
      for (var c = 0; c < 3; c++) {
        row[1 + x * 3 + c] = (rgba.getUint8(i + c) * a + 255 * (1 - a)).round();
      }
    }
    raw.add(Uint8List.fromList(row));
  }
  final ihdr = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2); // colour type RGB
  return (BytesBuilder()
        ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
        ..add(_chunk('IHDR', ihdr.buffer.asUint8List()))
        ..add(_chunk('IDAT', ZLibEncoder(level: 9).convert(raw.takeBytes())))
        ..add(_chunk('IEND', const [])))
      .takeBytes();
}

List<int> _chunk(String type, List<int> data) {
  final body = [...type.codeUnits, ...data];
  final out = ByteData(12 + data.length)..setUint32(0, data.length);
  for (var i = 0; i < body.length; i++) {
    out.setUint8(4 + i, body[i]);
  }
  out.setUint32(4 + body.length, _crc32(body));
  return out.buffer.asUint8List();
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = c & 1 != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}
