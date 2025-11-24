// import 'package:flutter/material.dart';

// class KalaakartLogo extends StatelessWidget {
//   final double size;
//   final bool showText;

//   // ignore: use_super_parameters
//   const KalaakartLogo({
//     Key? key,
//     this.size = 48,
//     this.showText = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(size * 0.25),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: CustomPaint(
//             painter: _KalaakartTreePainter(),
//           ),
//         ),
//         if (showText) ...[
//           SizedBox(width: size * 0.25),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 "Kalaakart",
//                 style: TextStyle(
//                   fontSize: size * 0.5,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.brown.shade800,
//                 ),
//               ),
//               Text(
//                 "CREATIVE HUB",
//                 style: TextStyle(
//                   fontSize: size * 0.23,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.brown.shade600,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
// }

// class _KalaakartTreePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
    
//     // Draw trunk
//     final trunkPaint = Paint()
//       ..color = const Color(0xFF8B4513)
//       ..style = PaintingStyle.fill;
    
//     final trunkPath = Path()
//       ..moveTo(center.dx - size.width * 0.08, center.dy + size.height * 0.15)
//       ..lineTo(center.dx - size.width * 0.05, center.dy - size.height * 0.05)
//       ..lineTo(center.dx + size.width * 0.05, center.dy - size.height * 0.05)
//       ..lineTo(center.dx + size.width * 0.08, center.dy + size.height * 0.15)
//       ..close();
    
//     canvas.drawPath(trunkPath, trunkPaint);

//     // Draw colorful leaves/branches
//     final leafColors = [
//       const Color(0xFFFF6B6B), // Red
//       const Color(0xFFFF9F43), // Orange
//       const Color(0xFFFECA57), // Yellow
//       const Color(0xFF48C9B0), // Teal
//       const Color(0xFF5F27CD), // Purple
//       const Color(0xFFEE5A6F), // Pink
//       const Color(0xFF00D2D3), // Cyan
//       const Color(0xFFFFA502), // Amber
//     ];

//     // Draw leaf clusters
//     final leafPositions = [
//       // Top cluster
//       Offset(center.dx, center.dy - size.height * 0.25),
//       Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.2),
//       Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.2),
      
//       // Middle cluster
//       Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.1),
//       Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.1),
//       Offset(center.dx - size.width * 0.15, center.dy),
//       Offset(center.dx + size.width * 0.15, center.dy),
      
//       // Lower cluster
//       Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.05),
//       Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.05),
//     ];

//     for (int i = 0; i < leafPositions.length; i++) {
//       final leafPaint = Paint()
//         ..color = leafColors[i % leafColors.length]
//         ..style = PaintingStyle.fill;
      
//       // Draw leaf shape (teardrop/petal)
//       final leafPath = Path();
//       final pos = leafPositions[i];
//       final leafSize = size.width * 0.08;
      
//       leafPath.moveTo(pos.dx, pos.dy - leafSize);
//       leafPath.quadraticBezierTo(
//         pos.dx + leafSize * 0.7, pos.dy - leafSize * 0.5,
//         pos.dx + leafSize * 0.3, pos.dy + leafSize * 0.3,
//       );
//       leafPath.quadraticBezierTo(
//         pos.dx, pos.dy + leafSize * 0.5,
//         pos.dx - leafSize * 0.3, pos.dy + leafSize * 0.3,
//       );
//       leafPath.quadraticBezierTo(
//         pos.dx - leafSize * 0.7, pos.dy - leafSize * 0.5,
//         pos.dx, pos.dy - leafSize,
//       );
      
//       canvas.drawPath(leafPath, leafPaint);
//     }

//     // Add small dots for detail
//     final dotPaint = Paint()..style = PaintingStyle.fill;
    
//     for (int i = 0; i < 5; i++) {
//       dotPaint.color = leafColors[(i * 2) % leafColors.length].withOpacity(0.6);
//       canvas.drawCircle(
//         Offset(
//           center.dx + (i - 2) * size.width * 0.08,
//           center.dy - size.height * 0.15 + (i % 2) * size.height * 0.05,
//         ),
//         size.width * 0.02,
//         dotPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // Small version for app bars and icons
// class KalaakartIcon extends StatelessWidget {
//   final double size;

//   const KalaakartIcon({Key? key, this.size = 32}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(size * 0.25),
//       ),
//       child: CustomPaint(
//         painter: _KalaakartTreePainter(),
//       ),
//     );
//   }
// }