import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({super.key});

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  bool isBatsman = false;
  bool isBowler = false;
  String? handedness;
  String? gender;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  File? profileImageFile;
  bool isUploading = false;

  final uid = FirebaseAuth.instance.currentUser!.uid; // ✅ Added UID here

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => profileImageFile = File(picked.path));
    }
  }

  Future<String?> uploadProfileImage(File file, String playerName) async {
    final ref = FirebaseStorage.instance.ref().child(
      'profile_photos/${playerName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
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
          'Add Player',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
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
          padding: EdgeInsets.all(42),
          children: [
            SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: pickProfileImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withOpacity(0.13),
                      backgroundImage: profileImageFile != null
                          ? FileImage(profileImageFile!)
                          : null,
                      child: profileImageFile == null
                          ? Icon(Icons.person, size: 70, color: Colors.white)
                          : null,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.tealAccent,
                      radius: 25,
                      child: Icon(Icons.camera_alt, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter name",
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: phoneController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Phone no. (optional)",
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Age",
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Player Role:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isBatsman,
                      onChanged: (val) =>
                          setState(() => isBatsman = val ?? false),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Batsman",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isBowler,
                      onChanged: (val) =>
                          setState(() => isBowler = val ?? false),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Bowler",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Text(
              "Handedness: ",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: "Right-handed",
                      groupValue: handedness,
                      onChanged: (val) => setState(() => handedness = val),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Righty",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "Left-handed",
                      groupValue: handedness,
                      onChanged: (val) => setState(() => handedness = val),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Lefty",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Text(
              "Gender:",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: "Male",
                      groupValue: gender,
                      onChanged: (val) => setState(() => gender = val),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Male",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "Female",
                      groupValue: gender,
                      onChanged: (val) => setState(() => gender = val),
                      activeColor: Colors.tealAccent,
                    ),
                    Text(
                      "Female",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),

            Center(
              child: isUploading
                  ? CircularProgressIndicator(color: Colors.tealAccent)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final playerName = nameController.text.trim();
                              final phone = phoneController.text.trim();
                              final ageStr = ageController.text.trim();
                              if (playerName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Player name is required!"),
                                  ),
                                );
                                return;
                              }
                              setState(() => isUploading = true);

                              // ✅ Modified duplicates check inside user's players only
                              final nameQuery = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('players')
                                  .where('name', isEqualTo: playerName)
                                  .get();

                              QuerySnapshot? phoneQuery;
                              if (phone.isNotEmpty) {
                                phoneQuery = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .collection('players')
                                    .where('phone', isEqualTo: phone)
                                    .get();
                              }

                              if (nameQuery.docs.isNotEmpty ||
                                  (phoneQuery != null &&
                                      phoneQuery.docs.isNotEmpty)) {
                                setState(() => isUploading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Player already exists!"),
                                  ),
                                );
                                return;
                              }

                              String? photoUrl;
                              if (profileImageFile != null) {
                                photoUrl = await uploadProfileImage(
                                  profileImageFile!,
                                  playerName,
                                );
                              }
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users') // ✅ Correct path
                                    .doc(uid)
                                    .collection('players')
                                    .add({
                                      'name': playerName,
                                      'phone': phone,
                                      'age': int.tryParse(ageStr),
                                      'photoUrl': photoUrl,
                                      'role': {
                                        'batsman': isBatsman,
                                        'bowler': isBowler,
                                      },
                                      'Handedness': {
                                        'left': handedness == "Left-handed",
                                        'right': handedness == "Right-handed",
                                      },
                                      'gender': {
                                        'male': gender == "Male",
                                        'female': gender == "Female",
                                      },
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Player created successfully!",
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e")),
                                );
                              }
                              setState(() => isUploading = false);
                            },

                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 15,
                              ),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
