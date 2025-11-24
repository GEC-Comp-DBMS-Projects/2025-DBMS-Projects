import 'package:flutter/material.dart';
import '../../models/event.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool isDarkMode = false;

  final List<Event> events = [
    Event(name: 'Tech Meetup', location: 'Mumbai', capacity: 75, filled: 60),
    Event(name: 'Music Fest', location: 'Goa', capacity: 100, filled: 80),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Discover Events'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final fillPercent = (e.filled / e.capacity * 100).round();
            return ListTile(
              title: Text(e.name),
              subtitle: Text('${e.location}  |  $fillPercent% full'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to event details
              },
            );
          },
        ),
      ),
    );
  }
}