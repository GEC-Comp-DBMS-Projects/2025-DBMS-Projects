import 'dart:ui';
import 'package:flutter/material.dart';
import '5manage.dart';
import '10startmatch.dart';
import 'auth_service.dart';
import '3authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '18matchestore.dart';

class ScoreMoreHome extends StatefulWidget {
  @override
  _ScoreMoreHomeState createState() => _ScoreMoreHomeState();
}

class _ScoreMoreHomeState extends State<ScoreMoreHome> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  Widget glassCard(String text, {VoidCallback? onTap}) {
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  // Retrieve current Firebase user
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,

      // Glassy Drawer with Gmail profile & Log Out
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(height: 12),

                          // Display Name
                          Text(
                            user?.displayName ??
                                (user?.email?.split('@').first ?? "Guest User"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              letterSpacing: 0.4,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black38,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 4),

                          // Email
                          Text(
                            user?.email ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.white),
                    title: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      await _authService.signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => AuthPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.25),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'scoremore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
            ],
            fontSize: 35,
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
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
              'Manage players',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageTeamsPlayersPage(),
                  ),
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
              'Start Match',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StartMatchPage()),
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
              onTap: (int idx) {
                setState(() => _currentIndex = idx);
                if (idx == 1) {
                  // Navigate to MatchListPage when Matches is tapped!
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MatchListPage()),
                  );
                } else if (idx == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UnderConstructionPage()),
                  );
                }
                // No action needed for idx == 0 (Home), since you're already there
              },
            ),
          ),
        ),
      ),
    );
  }
}

class UnderConstructionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        elevation: 0,
        title: Text("Coming Soon!", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build, color: Colors.white, size: 60),
                  SizedBox(height: 18),
                  Text(
                    "Feature Coming Soon!",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
