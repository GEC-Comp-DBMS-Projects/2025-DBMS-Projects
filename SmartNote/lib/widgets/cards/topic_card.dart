import 'package:flutter/material.dart';
import 'package:note_organiser/pages/topicpage.dart';

class TopicCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String topicID, dbPath;
  final bool isPending;

  const TopicCard({
    super.key,
    required this.data,
    required this.topicID,
    required this.dbPath,
    this.isPending = false,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  @override
  Widget build(BuildContext context) {
    // Get the current theme to style the card
    final theme = Theme.of(context);

    return Card(
      // Use the theme's color for the card background
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      // --- All visual effects removed for a flat design ---
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      clipBehavior: Clip.antiAlias, // Ensures ink splash is contained
      child: InkWell(
        // The InkWell provides a ripple effect on tap
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return TopicPage(
                  data: widget.data,
                  dbPath: widget.dbPath,
                  topicID: widget.topicID,
                  isPending: widget.isPending,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.article_outlined, // Icon representing a topic/document
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data['title'] ?? 'Untitled Topic',
                      // Use a text style from the theme
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display a status chip if the topic is pending
                    if (widget.isPending)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pending Approval',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      widget.data['description'] ?? "No description available.",
                      // Use a more subtle color for the description
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      maxLines: widget.isPending ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right navigation indicator icon
              Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: theme.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}