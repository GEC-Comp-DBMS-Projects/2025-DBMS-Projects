import 'package:flutter/material.dart';
import 'package:note_organiser/pages/subjectpage.dart';

class SubjectCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String subjectID, classID, userRole;

  const SubjectCard({
    super.key,
    required this.data,
    required this.subjectID,
    required this.classID,
    required this.userRole,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Color palette for different subjects (cycles through based on name hash)
  final List<List<Color>> _colorPalettes = [
    [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Purple-Indigo
    [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // Pink-Rose
    [const Color(0xFF14B8A6), const Color(0xFF06B6D4)], // Teal-Cyan
    [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber-Red
    [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald-Green
    [const Color(0xFF8B5CF6), const Color(0xFFD946EF)], // Violet-Fuchsia
  ];

  // Icon options based on subject name
  IconData _getSubjectIcon() {
    final name = widget.data['name']?.toString().toLowerCase() ?? '';
    
    if (name.contains('math') || name.contains('calculus') || name.contains('algebra')) {
      return Icons.calculate_outlined;
    } else if (name.contains('science') || name.contains('physics') || name.contains('chemistry')) {
      return Icons.science_outlined;
    } else if (name.contains('history') || name.contains('social')) {
      return Icons.history_edu_outlined;
    } else if (name.contains('english') || name.contains('literature') || name.contains('language')) {
      return Icons.menu_book_outlined;
    } else if (name.contains('art') || name.contains('design')) {
      return Icons.palette_outlined;
    } else if (name.contains('computer') || name.contains('programming') || name.contains('code')) {
      return Icons.computer_outlined;
    } else if (name.contains('music')) {
      return Icons.music_note_outlined;
    } else if (name.contains('geography')) {
      return Icons.public_outlined;
    } else if (name.contains('biology')) {
      return Icons.biotech_outlined;
    } else {
      return Icons.book_outlined;
    }
  }

  List<Color> _getColorPalette() {
    final nameHash = (widget.data['name'] ?? '').hashCode.abs();
    return _colorPalettes[nameHash % _colorPalettes.length];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColorPalette();
    final icon = _getSubjectIcon();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            elevation: 0,
            child: InkWell(
              onTap: () {
                _controller.forward().then((_) => _controller.reverse());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SubjectPage(
                        data: widget.data,
                        classID: widget.classID,
                        subjectID: widget.subjectID,
                        userRole: widget.userRole,
                      );
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Image Container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.data['imageUrl'] != null
                          ? Image.network(
                              widget.data['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: colors,
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: colors,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.data['name'] ?? 'Untitled Subject',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                             
                              
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.data['description'] ?? "No description available",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Bottom Info Row
                          Row(
                            children: [
                              // Topics Count (if available)
                              if (widget.data.containsKey('topicCount'))
                                _buildInfoChip(
                                  icon: Icons.topic_outlined,
                                  label: '${widget.data['topicCount']} topics',
                                  color: colors[0],
                                ),
                              
                              const Spacer(),
                              
                              // Arrow indicator
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colors[0].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: colors[0],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}