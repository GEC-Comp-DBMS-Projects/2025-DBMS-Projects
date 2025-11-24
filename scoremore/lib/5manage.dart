import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:scoremore/4home.dart';
import '6addplayer.dart';
import '7editplayer.dart';
import '9deleteplayer.dart';

class ManageTeamsPlayersPage extends StatefulWidget {
  @override
  _ManageTeamsPlayersPageState createState() => _ManageTeamsPlayersPageState();
}

class _ManageTeamsPlayersPageState extends State<ManageTeamsPlayersPage> {
  int _currentIndex = 0;

  Widget glassCard(String text, IconData icon, {VoidCallback? onTap}) {
    Widget card = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(36.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  size: 30,
                ),
                SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center, // 👈 centers text
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Players',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
            ],
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF179197), Color(0xFF307380), Color(0xFF015B63)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25),
              BlendMode.darken,
            ),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 100, horizontal: 0),
          children: [
            glassCard(
              'Add players',
              Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPlayerPage()),
                );
              },
            ),

            // Translucent Line
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 40.0,
              ),
              child: Divider(
                color: Colors.white.withOpacity(0.4), // translucent white
                thickness: 1.5,
              ),
            ),
            glassCard(
              'Edit Player',
              Icons.edit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPlayer(),
                  ), // Navigate to EditPlayer from 7editplayer.dart
                );
              },
            ),
            // Translucent Line
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 40.0,
              ),
              child: Divider(
                color: Colors.white.withOpacity(0.4), // translucent white
                thickness: 1.5,
              ),
            ),
            glassCard(
              'Delete Player',
              Icons.delete,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletePlayersPage()),
                );
              },
            ),

            SizedBox(height: 24),
          ],
        ),
      ),

      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _currentIndex,
              onTap: (int idx) {
                setState(() {
                  _currentIndex = idx;
                });
                if (idx == 0) {
                  // This is Home, perform navigation or pop
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScoreMoreHome()),
                  );
                }
                if (idx == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (content) => UnderConstructionPage(),
                    ),
                  );
                }
                // Add more logic for other indices as needed
              },
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromARGB(255, 196, 198, 198),
              selectedLabelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 28),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_cricket, size: 28),
                  label: "Matches",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv, size: 28),
                  label: "Live Score",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
