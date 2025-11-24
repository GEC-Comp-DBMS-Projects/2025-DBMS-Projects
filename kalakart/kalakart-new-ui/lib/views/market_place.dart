import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kart_app/models/products_model.dart';
import 'package:kart_app/containers/category_container.dart';
import 'package:kart_app/containers/market_place_maker_container.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({super.key});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = "";
  String _searchLower = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        titleSpacing: 16,
        // use logo.png from assets as app icon/title
        title: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.orange.shade50,
                      child: Icon(
                        Icons.storefront,
                        color: Colors.orange.shade700,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kalaakart',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Creative Rental Studio',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with gradient background
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? Colors.orange.shade200
                        : Colors.grey.shade200,
                    width: _searchQuery.isNotEmpty ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: _searchQuery.isNotEmpty
                          ? Colors.orange.shade600
                          : Colors.grey.shade500,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search equipment, studios...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          if (_debounce?.isActive ?? false) {
                            _debounce!.cancel();
                          }
                          _debounce = Timer(
                            const Duration(milliseconds: 400),
                            () {
                              setState(() {
                                _searchLower = value.trim().toLowerCase();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                            _searchLower = "";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Products List
            Expanded(
              child: _searchQuery.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          CategoryContainer(),
                          const SizedBox(height: 8),
                          MarketPlaceMakerContainer(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    )
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final stream = FirebaseFirestore.instance
        .collection('shop_products')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.orange.shade600,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading products...',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        final lower = _searchLower;
        List<ProductsModel> all = ProductsModel.fromJsonList(
          snapshot.data!.docs,
        );
        List<ProductsModel> results = all
            .where((p) => p.name.toLowerCase().contains(lower))
            .toList();

        if (results.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final product = results[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(ProductsModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/view_product', arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: Colors.orange.shade400,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 40,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.brown.shade900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade600,
                            Colors.orange.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade300.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KalaakartIcon extends StatelessWidget {
  final double size;
  const KalaakartIcon({Key? key, this.size = 32}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
