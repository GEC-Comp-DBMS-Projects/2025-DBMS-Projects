import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool hasPlacedOrder = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkUserOrders();
  }

  Future<void> _checkUserOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final query = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      setState(() {
        hasPlacedOrder = query.docs.isNotEmpty;
        loading = false;
      });
    } else {
      setState(() {
        hasPlacedOrder = false;
        loading = false;
      });
    }
  }

  Future<void> submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    if (!hasPlacedOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must place an order before submitting feedback"),
        ),
      );
      return;
    }

    if (rating == 0 || _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and comment")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': user.uid,
        'rating': rating,
        'comment': _commentController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _commentController.clear();
      setState(() {
        rating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting feedback: $e")));
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: index <= rating ? Colors.orange : Colors.grey[400],
      ),
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF625D9F),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Feedback",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Only allow feedback if user has placed an order
            if (user != null && hasPlacedOrder) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => buildStar(index + 1)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter your comment",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF625D9F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Submit Feedback",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else if (user != null && !hasPlacedOrder) ...[
              Text(
                "You must place an order before submitting feedback.",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              Text(
                "Please log in to submit feedback.",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
            ],

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Feedback",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feedbacks')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No feedback yet",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  final feedbacks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final fb =
                          feedbacks[index].data() as Map<String, dynamic>;
                      final fbRating = fb['rating'] ?? 0;
                      final fbComment = fb['comment'] ?? "";

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                color: i < fbRating
                                    ? Colors.orange
                                    : Colors.grey[300],
                                size: 20,
                              ),
                            ),
                          ),
                          title: Text(fbComment, style: GoogleFonts.poppins()),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
