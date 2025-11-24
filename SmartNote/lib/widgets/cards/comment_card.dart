import 'package:flutter/material.dart';

class CommentCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String commentID, dbPath;
  final bool myComment;
  const CommentCard({
    super.key,
    required this.data,
    required this.commentID,
    required this.dbPath,
    this.myComment = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  void editComment() {}

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Text(widget.data['author'], style: TextStyle(fontSize: 11)),
            const Spacer(),
            if (widget.myComment)
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data['message'], style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.reply)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
