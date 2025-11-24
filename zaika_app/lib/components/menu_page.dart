import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String selectedCategory = 'Non-Veg';

  // Keep all fetched items globally by id
  Map<String, Map<String, dynamic>> allItems = {};
  List<Map<String, dynamic>> displayedItems = [];

  // Track quantities and spice levels by itemId
  Map<String, int> itemCounts = {};
  Map<String, String> itemSpiceLevels = {};

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('food_items').get();

      Map<String, Map<String, dynamic>> newAllItems = {};

      for (var doc in querySnapshot.docs) {
        final menuData = doc.data()['menuItems'] as Map<String, dynamic>?;
        if (menuData != null) {
          menuData.forEach((key, value) {
            newAllItems[key] = {
              'id': key,
              'name': value['name'],
              'price': value['price'],
              'image_url': value['image_url'],
              'description': value['description'] ?? '',
              'preparation_time': value['preparation_time'] ?? 0,
              'category': value['category'],
            };
          });
        }
      }

      setState(() {
        allItems = newAllItems;
        _updateDisplayedItems();
      });
    } catch (e) {
      print("🔥 Error fetching menu items: $e");
    }
  }

  void _updateDisplayedItems() {
    displayedItems = allItems.values
        .where((item) => item['category'] == selectedCategory)
        .toList();
  }

  Future<void> _placeOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please log in first.")));
        return;
      }

      List<Map<String, dynamic>> orderItems = [];
      double total = 0;

      itemCounts.forEach((itemId, qty) {
        final item = allItems[itemId];
        if (item != null) {
          orderItems.add({
            'itemId': item['id'],
            'name': item['name'],
            'quantity': qty,
            'price': item['price'],
            'image_url': item['image_url'],
            'spiceLevel': itemSpiceLevels[itemId] ?? '',
          });
          total += (item['price'] * qty);
        }
      });

      if (orderItems.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No items selected.")));
        return;
      }

      final orderId = "order_${DateTime.now().millisecondsSinceEpoch}";

      final newOrder = {
        'userId': user.uid,
        'items': orderItems,
        'totalAmount': total,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(newOrder);

      setState(() {
        itemCounts.clear();
        itemSpiceLevels.clear();
      });

      // Navigate to OrdersPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrdersPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF625D9F),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Menu',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Category chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Veg', 'Non-Veg', 'Drinks', 'Dessert']
                    .map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) => setState(() {
                            selectedCategory = cat;
                            _updateDisplayedItems();
                          }),
                          selectedColor: const Color(0xFF625D9F),
                          labelStyle: TextStyle(
                            color: selectedCategory == cat
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Menu List
            Expanded(
              child: displayedItems.isEmpty
                  ? const Center(child: Text("No items in this category."))
                  : ListView.builder(
                      itemCount: displayedItems.length,
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        final count = itemCounts[item['id']] ?? 0;
                        final selectedSpice = itemSpiceLevels[item['id']];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['image_url'],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹ ${item['price']}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item['description'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Spice level for Veg / Non-Veg
                                if (['Veg', 'Non-Veg'].contains(selectedCategory))
                                  Row(
                                    children: [
                                      ChoiceChip(
                                        label: const Text("Mild 🌶"),
                                        selected: selectedSpice == "Mild",
                                        onSelected: (_) => setState(
                                          () => itemSpiceLevels[item['id']] = "Mild",
                                        ),
                                        selectedColor: Colors.orangeAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      ChoiceChip(
                                        label: const Text("Medium 🌶🌶"),
                                        selected: selectedSpice == "Medium",
                                        onSelected: (_) => setState(
                                          () => itemSpiceLevels[item['id']] = "Medium",
                                        ),
                                        selectedColor: Colors.deepOrangeAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      ChoiceChip(
                                        label: const Text("Spicy 🌶🌶🌶"),
                                        selected: selectedSpice == "Spicy",
                                        onSelected: (_) => setState(
                                          () => itemSpiceLevels[item['id']] = "Spicy",
                                        ),
                                        selectedColor: Colors.redAccent,
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),

                                // Qty buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Qty:",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    count == 0
                                        ? ElevatedButton(
                                            onPressed: () => setState(
                                              () => itemCounts[item['id']] = 1,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF625D9F,
                                              ),
                                            ),
                                            child: const Text("Add"),
                                          )
                                        : Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () => setState(() {
                                                  if (count > 1) {
                                                    itemCounts[item['id']] = count - 1;
                                                  } else {
                                                    itemCounts.remove(item['id']);
                                                    itemSpiceLevels.remove(item['id']);
                                                  }
                                                }),
                                              ),
                                              Text(
                                                '$count',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () => setState(() {
                                                  itemCounts[item['id']] = count + 1;
                                                }),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Confirm Order
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF625D9F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Confirm Order",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
