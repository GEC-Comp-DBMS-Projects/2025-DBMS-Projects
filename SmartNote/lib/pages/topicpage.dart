import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:note_organiser/data/globaldata.dart';
import 'package:note_organiser/widgets/Text_field.dart';
import 'package:note_organiser/widgets/cards/comment_card.dart';
import 'package:note_organiser/pages/detailpage.dart';

class TopicPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String topicID, dbPath;
  final bool isPending;
  const TopicPage({
    super.key,
    required this.data,
    required this.dbPath,
    required this.topicID,
    this.isPending = false,
  });

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  bool isImage = false, isPDF = false;
  void addComment(String comment) async {
    await FirebaseFirestore.instance
        .collection(widget.dbPath)
        .doc(widget.topicID)
        .collection('comments')
        .add({
          'message': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'author': globalEmail,
          'replied to': 'main content',
        });
  }

  void acceptNote() {
    FirebaseFirestore.instance
        .collection(widget.dbPath)
        .doc(widget.topicID)
        .update({'status': 'accepted', 'accepted by': globalEmail});
    Navigator.pop(context);
  }

  void deleteNote() {
    FirebaseFirestore.instance
        .collection(widget.dbPath)
        .doc(widget.topicID)
        .update({'status': 'rejected', 'rejected by': globalEmail});
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (widget.data.containsKey('link')) {
      if(widget.data['link'].isEmpty){
        return;
      }
      isPDF = widget.data['link'].toString().contains('.pdf');
      isImage = !isPDF;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.data['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                if (!isImage && !isPDF) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(data: widget.data),
                    ),
                  );
                }
              },
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['title'] ?? "No Subtitle",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "By ${widget.data['author']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      if (!isImage && !isPDF)
                        Text(
                          widget.data['description'],
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      if (isImage)
                        Image.network(
                          widget.data['link'],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      if (isPDF) ...[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: PDF().cachedFromUrl(
                            widget.data['link'],
                            placeholder:
                                (progress) =>
                                    Center(child: Text('$progress %')),
                            errorWidget:
                                (error) =>
                                    Center(child: Text(error.toString())),
                          ),
                        ),
                        Row(),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (widget.isPending) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => acceptNote(),
                    child: Text('Accpet Note'),
                  ),
                  TextButton(
                    onPressed: () => deleteNote(),
                    child: Text('Decline Note'),
                  ),
                ],
              ),
            ],

            if (widget.isPending == false) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  "Comments",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommentTextField(
                  label: "Add a comments",
                  onSend: (p0) async {
                    addComment(p0);
                  },
                ),
              ),

              const SizedBox(height: 8),

              StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection(widget.dbPath)
                        .doc(widget.topicID)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return CommentCard(
                        data: docs[index].data(),
                        dbPath: "${widget.dbPath}/${widget.topicID}/comments",
                        commentID: docs[index].id,
                        myComment: docs[index].data()['author'] == globalEmail,
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
