import 'package:flutter/material.dart';

class MosqueArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Start from bottom-left
    path.lineTo(0, size.height);
    // Go to bottom-right
    path.lineTo(size.width, size.height);
    // Go to top-right
    path.lineTo(size.width, size.height * 0.2);
    // Create the arch
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.05, 0, size.height * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}