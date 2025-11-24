import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewItemsPage extends StatelessWidget {
  const ViewItemsPage({super.key});

  Future<void> _deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('food_items')
          .doc(docId)
          .delete();
      debugPrint('✅ Deleted item with ID: $docId');
    } catch (e) {
      debugPrint('❌ Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Items'),
        backgroundColor: const Color(0xFF8173C3),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('food_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('⚠️ No data found in Firestore collection.');
            return const Center(
              child: Text(
                'No items found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final rawData = doc.data() as Map<String, dynamic>? ?? {};

              // ✅ Extract inner item map
              Map<String, dynamic> data = {};
              if (rawData.containsKey('menuItems')) {
                final innerMap = rawData['menuItems'] as Map<String, dynamic>;
                if (innerMap.isNotEmpty) {
                  data = innerMap.values.first as Map<String, dynamic>;
                }
              }

              debugPrint('🧾 Item extracted: ${data.toString()}');

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: data['image_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['image_url'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.fastfood,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                  title: Text(
                    data['name'] ?? 'Unnamed Item',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${data['category'] ?? 'N/A'}'),
                      Text('Price: ₹${data['price'] ?? '-'}'),
                      Text(
                        'Prep Time: ${data['preparation_time'] ?? '-'} mins',
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _showDeleteDialog(context, doc.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteItem(docId);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
