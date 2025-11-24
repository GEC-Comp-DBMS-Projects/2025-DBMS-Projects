import 'package:flutter/material.dart';
import 'package:note_organiser/pages/classpage%20pages/classpage.dart';

class LogoCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const LogoCard({super.key, required this.data});

  @override
  State<LogoCard> createState() => _LogoCardState();
}
class _LogoCardState extends State<LogoCard> {
  final List<String> _fallbackImages = [
    'assets/down_book.jpg',
    'assets/down_book2.jpg',
    'assets/down_book3.jpg',
    'assets/down_book4.jpeg',
  ];

  String get _displayImage {
    if (widget.data['image'] != null && widget.data['image'].isNotEmpty) {
      return widget.data['image'];
    }
    final index = (widget.data['name'] ?? '').hashCode % _fallbackImages.length;
    return _fallbackImages[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassPage(
              data: widget.data,
              classID: widget.data['id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        height: 220,
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image
            Container(
              height: 100,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  _displayImage,
                  fit: BoxFit.cover, // fills fully
                ),
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data['name'] ?? 'Class',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.data['description'] ?? 'No description',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(widget.data['participants'] as List?)?.length ?? 0}',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                     
                      ],
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
