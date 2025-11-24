// Zone container: shows up to 4 products in a two-column layout.
// Images are displayed fully (BoxFit.contain) so nothing is cropped.
// Mobile-optimized with proper spacing and touch targets.
// Now includes pricing information with proper fit.

import 'package:flutter/material.dart';
import 'package:kart_app/controllers/db_service.dart';
import 'package:kart_app/models/products_model.dart';
import 'package:shimmer/shimmer.dart';

class ZoneContainer extends StatefulWidget {
  final String category;
  const ZoneContainer({super.key, required this.category});

  @override
  State<ZoneContainer> createState() => _ZoneContainerState();
}

class _ZoneContainerState extends State<ZoneContainer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DbService().readProducts(widget.category),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ProductsModel> products = ProductsModel.fromJsonList(snapshot.data!.docs);
          if (products.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          // Show a pale background with rounded cards arranged in two columns
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with category title and chevron
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        "${widget.category.substring(0, 1).toUpperCase() + widget.category.substring(1)}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/specific", arguments: {"name": widget.category});
                        },
                        icon: const Icon(Icons.chevron_right),
                      )
                    ],
                  ),
                ),

                // Grid-like two-column layout using GridView. Show up to 4 items.
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.58, // Increased height to fit all content
                  padding: EdgeInsets.zero,
                  children: List.generate(
                    (products.length > 4 ? 4 : products.length),
                    (i) {
                      final p = products[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/view_product", arguments: p),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top row: discount badge only (removed favorite icon)
                              if (p.old_price > p.new_price)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${(((p.old_price - p.new_price) / p.old_price) * 100).round()}% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 28), // Maintain consistent spacing

                              const SizedBox(height: 8),

                              // Product image area: use BoxFit.contain so the full image is visible
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 110, // Reduced image height slightly
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: Image.network(
                                    p.image,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Stock quantity and availability badge
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Stock: ${p.maxQuantity > 0 ? p.maxQuantity : 0}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: p.maxQuantity == 0 ? Colors.red.shade100 : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      p.maxQuantity == 0 ? 'Out of stock' : 'Available',
                                      style: TextStyle(
                                        color: p.maxQuantity == 0 ? Colors.red.shade800 : Colors.green.shade800,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Verified pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 11, color: Colors.green.shade700),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Title
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              
                              const SizedBox(height: 3),
                              
                              // Description
                              Text(
                                p.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                  height: 1.2,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Price section - now with better wrapping
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '₹${p.new_price}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (p.old_price > p.new_price)
                                      Text(
                                        '₹${p.old_price}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return Shimmer(
          child: Container(height: 400, width: double.infinity, color: Colors.white),
          gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.white]),
        );
      },
    );
  }
}