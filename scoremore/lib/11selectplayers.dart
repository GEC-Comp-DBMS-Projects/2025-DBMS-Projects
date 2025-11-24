import 'dart:ui';
import 'package:flutter/material.dart';
import '12selectmenu.dart';
import '13tossnover.dart';

class SelectPlayersPage extends StatefulWidget {
  final String team1;
  final String team2;
  final String matchId;

  const SelectPlayersPage({
    super.key,
    required this.team1,
    required this.team2,
    required this.matchId,
  });

  @override
  State<SelectPlayersPage> createState() => _SelectPlayersPageState();
}

class _SelectPlayersPageState extends State<SelectPlayersPage> {
  List<String>? selectedTeam1Players;
  List<String>? selectedTeam2Players;

  Widget glassCard(String text, {VoidCallback? onTap}) {
    Widget card = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(36.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 22,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  Widget glassbutton(String text, {VoidCallback? onTap}) {
    Widget card = Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(36.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 22,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.22),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Select Players',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 20, color: Colors.black54)],
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: const DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight + 50),
              glassCard(
                '${widget.team1} players',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChecklistSelectPlayersPage(
                        teamName: widget.team1,
                        matchId: widget.matchId,
                        teamKey: 'teamA',
                        exclude: [],
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      selectedTeam1Players = (result as List).cast<String>();
                    });
                    debugPrint("✅ Team A selected: $selectedTeam1Players");
                  }
                },
              ),
              glassCard(
                '${widget.team2} players',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChecklistSelectPlayersPage(
                        teamName: widget.team2,
                        matchId: widget.matchId,
                        teamKey: 'teamB',
                        exclude: selectedTeam1Players ?? [],
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      selectedTeam2Players = (result as List).cast<String>();
                    });
                    debugPrint("✅ Team B selected: $selectedTeam2Players");
                  }
                },
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 30),
                child: SizedBox(
                  width: double.infinity,
                  child: glassbutton(
                    'Next',
                    onTap: () {
                      if (selectedTeam1Players == null ||
                          selectedTeam2Players == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select players for both teams!",
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TossAndOver(
                            team1: widget.team1,
                            team2: widget.team2,
                            matchId: widget.matchId,
                          ),
                        ),
                      );
                      debugPrint("✅ Proceeding to next page...");
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
