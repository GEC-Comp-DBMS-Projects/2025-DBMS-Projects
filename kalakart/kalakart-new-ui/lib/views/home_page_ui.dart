import 'package:flutter/material.dart';

class HomePageUi extends StatefulWidget {
  @override
  State<HomePageUi> createState() => _HomePageUiState();
}

class _HomePageUiState extends State<HomePageUi> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_selectedIndex) {
      default:
        body = _mainHomeBody(context);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: const KalaakartIcon(size: 36),
              ),
              Text(
                "Kalaakart",
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.brown),
                onPressed: () {},
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  "Create",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F7F4),
      body: body,
    );
  }

  Widget _mainHomeBody(BuildContext context) {
    const List<Map<String, dynamic>> featuredItems = [
      {
        "name": "Priya Sharma",
        "location": "Mumbai",
        "time": "2h",
        "tag": "Design",
        "icon": Icons.palette,
        "iconColor": Colors.orange,
        "description": "Minimalist leaf illustration for eco campaign.",
        "image": Icons.eco,
        "imageColor": Colors.lightGreen,
        "views": "1,200",
      },
      {
        "name": "Arjun Patel",
        "location": "Delhi",
        "time": "5h",
        "tag": "Photography",
        "icon": Icons.camera_alt,
        "iconColor": Colors.blue,
        "description": "Wedding shoot highlights from last weekend.",
        "image": Icons.camera,
        "imageColor": Colors.blueAccent,
        "views": "980",
      },
      {
        "name": "Maya Rao",
        "location": "Bangalore",
        "time": "1d",
        "tag": "Music",
        "icon": Icons.music_note,
        "iconColor": Colors.purple,
        "description": "Join my online music classes for beginners.",
        "image": Icons.music_video,
        "imageColor": Colors.deepPurple,
        "views": "2,340",
      },
      {
        "name": "Kavi Singh",
        "location": "Jaipur",
        "time": "3d",
        "tag": "Wedding",
        "icon": Icons.emoji_events,
        "iconColor": Colors.red,
        "description": "Traditional wedding planning and decor.",
        "image": Icons.favorite,
        "imageColor": Colors.redAccent,
        "views": "1,050",
      },
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search creators, projects...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF3ECE6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _storyCircle("Priya", Icons.palette, true),
                _storyCircle("Arjun", Icons.movie),
                _storyCircle("Maya", Icons.camera_alt),
                _storyCircle("Kavi", Icons.emoji_events),
                _storyCircle("Ravi", Icons.music_note),
              ],
            ),
          ),
          const Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Featured Work",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: featuredItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: _featuredCard(context, item),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _storyCircle(String name, IconData icon, [bool selected = false]) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.orange : Colors.brown.shade100,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.orange[50],
              child: Icon(icon, color: Colors.orange[700], size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: Colors.brown[700],
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.brown.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[50],
                  child: Icon(item["icon"], color: item["iconColor"]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.brown[300],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item["location"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[400],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("•", style: TextStyle(color: Colors.brown[300])),
                          const SizedBox(width: 8),
                          Text(
                            item["time"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item["tag"],
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item["description"],
                style: TextStyle(color: Colors.brown[400], fontSize: 13),
              ),
            ),
          ),
          Container(
            height: 140,
            color: const Color(0xFFF3F1ED),
            child: Center(
              child: Icon(item["image"], color: item["imageColor"], size: 60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown[700],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item["views"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Logo widget classes
class KalaakartIcon extends StatelessWidget {
  final double size;
  const KalaakartIcon({Key? key, this.size = 32}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: CustomPaint(painter: _KalaakartTreePainter()),
    );
  }
}

class _KalaakartTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;
    final trunkPath = Path()
      ..moveTo(center.dx - size.width * 0.08, center.dy + size.height * 0.15)
      ..lineTo(center.dx - size.width * 0.05, center.dy - size.height * 0.05)
      ..lineTo(center.dx + size.width * 0.05, center.dy - size.height * 0.05)
      ..lineTo(center.dx + size.width * 0.08, center.dy + size.height * 0.15)
      ..close();
    canvas.drawPath(trunkPath, trunkPaint);

    final leafColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFF9F43),
      const Color(0xFFFECA57),
      const Color(0xFF48C9B0),
      const Color(0xFF5F27CD),
      const Color(0xFFEE5A6F),
      const Color(0xFF00D2D3),
      const Color(0xFFFFA502),
    ];

    final leafPositions = [
      Offset(center.dx, center.dy - size.height * 0.25),
      Offset(center.dx - size.width * 0.12, center.dy - size.height * 0.2),
      Offset(center.dx + size.width * 0.12, center.dy - size.height * 0.2),
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.1),
      Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.1),
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.05),
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.05),
    ];

    for (int i = 0; i < leafPositions.length; i++) {
      final leafPaint = Paint()
        ..color = leafColors[i % leafColors.length]
        ..style = PaintingStyle.fill;
      final leafPath = Path();
      final pos = leafPositions[i];
      final leafSize = size.width * 0.08;
      leafPath.moveTo(pos.dx, pos.dy - leafSize);
      leafPath.quadraticBezierTo(
        pos.dx + leafSize * 0.7,
        pos.dy - leafSize * 0.5,
        pos.dx + leafSize * 0.3,
        pos.dy + leafSize * 0.3,
      );
      leafPath.quadraticBezierTo(
        pos.dx,
        pos.dy + leafSize * 0.5,
        pos.dx - leafSize * 0.3,
        pos.dy + leafSize * 0.3,
      );
      leafPath.quadraticBezierTo(
        pos.dx - leafSize * 0.7,
        pos.dy - leafSize * 0.5,
        pos.dx,
        pos.dy - leafSize,
      );
      canvas.drawPath(leafPath, leafPaint);
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      dotPaint.color = leafColors[(i * 2) % leafColors.length].withOpacity(0.6);
      canvas.drawCircle(
        Offset(
          center.dx + (i - 2) * size.width * 0.08,
          center.dy - size.height * 0.15 + (i % 2) * size.height * 0.05,
        ),
        size.width * 0.02,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
