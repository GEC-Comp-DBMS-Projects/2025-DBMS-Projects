import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../home_page.dart'; // 👈 adjust path if needed

class ChatbotPage extends StatefulWidget {
  final String uid;
  final String role;

  const ChatbotPage({super.key, required this.uid, required this.role});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  List<Map<String, dynamic>> _events = [];
  bool _isLoadingEvents = true;
  bool isDarkMode = true; // Added theme toggle state

  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: 'AIzaSyCZu8tuBtZqDRNZBiDBYHHgZOjLQCCn3F4',
  );

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('crowdr')
          .doc('events')
          .collection('events')
          .get();

      setState(() {
        _events = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['title'] ?? 'Unknown Event',
            'description': data['description'] ?? 'No description available.',
            'date': data['date'] ?? 'No date specified.',
            'location': data['location'] ?? 'No location specified.',
          };
        }).toList();
        _isLoadingEvents = false;
      });
    } catch (e) {
      print("Error fetching events: $e");
      setState(() {
        _isLoadingEvents = false;
      });
      _addBotMessage("Failed to load events. Please check your internet connection and try again.");
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    _controller.clear();
    _scrollToBottom();
    _getBotResponse(text);
  }

  Future<void> _getBotResponse(String query) async {
    _addBotMessage("...");

    if (_isLoadingEvents) {
      _messages.removeLast();
      _addBotMessage("I'm still fetching event info, please wait a moment!");
      return;
    }

    if (_events.isEmpty) {
      _messages.removeLast();
      _addBotMessage("I don't have any event information right now. Please check back later.");
      return;
    }

    final sanitizedQuery = query.toLowerCase();

    final eventKeywords = ["event", "events", "conference", "meeting", "hackathon", "show", "festival", "what's happening", "upcoming", "tell me about"];
    final isEventQuestion = eventKeywords.any((kw) => sanitizedQuery.contains(kw)) ||
                            _events.any((event) => sanitizedQuery.contains(event['title'].toString().toLowerCase()));

    if (!isEventQuestion && !sanitizedQuery.contains("hello") && !sanitizedQuery.contains("hi")) {
      _messages.removeLast();
      _addBotMessage("I can only answer questions related to events 🎭. Try asking about a specific event or what's happening!");
      return;
    }

    try {
      final prompt = """
      You are an event assistant chatbot named CrowdrBot. Your primary goal is to provide information about events.
      
      Here is the list of current and upcoming events:
      ${_events.map((e) => "Title: ${e['title']}, Date: ${e['date']}, Location: ${e['location']}, Description: ${e['description']}").join("\n\n")}
      
      User Query: "$query"
      
      Based strictly on the provided event data:
      - If the query asks for general event information, list relevant events with their titles, dates, and locations.
      - If the query asks for details about a specific event, provide the title, date, location, and description for that event.
      - If you cannot find information about a specific event mentioned, politely state that you don't have details for it.
      - If the query is a greeting, respond kindly and offer to help with event information.
      - Do not invent information not present in the provided event data.
      - Keep your responses concise and helpful.
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? "I'm not sure how to answer that based on the event information I have.";
      _messages.removeLast();
      _addBotMessage(text);
    } catch (e) {
      print("Error generating content: $e");
      _messages.removeLast();
      _addBotMessage("Sorry, something went wrong while processing your request. Please try again.");
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'sender': 'bot', 'text': text});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define light and dark colors
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.deepPurple : Colors.deepPurple.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintColor = isDarkMode ? Colors.grey : Colors.grey.shade600;
    final userBubbleColor = isDarkMode ? Colors.deepPurple : Colors.deepPurple.shade200;
    final botBubbleColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final dividerColor = isDarkMode ? Colors.white24 : Colors.black12;
    final loadingTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Chatbot Assistant",
          style: TextStyle(color: textColor),
        ),
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  uid: widget.uid,
                  role: widget.role,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingEvents
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: appBarColor),
                        const SizedBox(height: 16),
                        Text(
                          "Loading events...",
                          style: TextStyle(color: loadingTextColor, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? userBubbleColor : botBubbleColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['text']!,
                            style: TextStyle(
                              color: isUser 
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? Colors.white : Colors.black87),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1, color: dividerColor),
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Ask about events...",
                        hintStyle: TextStyle(color: hintColor),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: appBarColor),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}