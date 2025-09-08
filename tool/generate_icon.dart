import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final bg = img.ColorRgba8(0x00, 0x6A, 0x71, 0xFF); // theme primary
  final white = img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);

  final canvas = img.Image(width: size, height: size);
  // Fill background
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      canvas.setPixel(x, y, bg);
    }
  }

  // Draw crescent: large white circle minus a slightly offset bg circle
  final cx = (size * 0.44).toInt();
  final cy = (size * 0.50).toInt();
  final rOuter = (size * 0.28).toInt();
  final rInner = (size * 0.28).toInt();

  // Outer white disk
  // Filled outer circle (white)
  _fillCircle(canvas, cx, cy, rOuter, white);
  // Inner cutout disk with bg color offset to the right to create crescent
  final innerCx = (size * 0.56).toInt();
  // Filled inner cutout circle (bg)
  _fillCircle(canvas, innerCx, cy, rInner, bg);

  // Save
  final bytes = img.encodePng(canvas);
  final outDir = Directory('assets/icon');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final out = File('assets/icon/app_icon.png');
  out.writeAsBytesSync(bytes);
  stdout.writeln('Wrote assets/icon/app_icon.png');
}

void _fillCircle(img.Image image, int cx, int cy, int r, img.Color color) {
  final r2 = r * r;
  for (int y = -r; y <= r; y++) {
    for (int x = -r; x <= r; x++) {
      if (x * x + y * y <= r2) {
        image.setPixel(cx + x, cy + y, color);
      }
    }
  }
}
