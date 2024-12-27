import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:userapp/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PlayerListScreen(),
    );
  }
}

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(
            'USER APP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search players...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color(0xff26278D)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('players').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No players found.'));
                }

                // Filter players based on search query
                final players = snapshot.data!.docs.where((player) {
                  final playerName = player['name'].toLowerCase();
                  return playerName.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final imageBase64 = player['image_base64'];
                    return Card(
                      elevation: 2,
                      color: AppColors.cardBaground,
                      child: ListTile(
                        leading: imageBase64 != null && imageBase64.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.memory(
                                  base64Decode(imageBase64),
                                  height: 50,
                                  width: 50,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  color: Colors.white,
                                  height: 50,
                                  width: 50,
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),
                              ),
                        title: Text(player['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300),
                            'Age: ${player['age']}, Score: ${player['total_score']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerDetailsScreen(
                                player: player,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot player;

  const PlayerDetailsScreen({required this.player, super.key});

  @override
  Widget build(BuildContext context) {
    final imageBase64 = player['image_base64'];
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the desired color for the back button
        ),
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          "Player Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppColors.cardBaground,
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  imageBase64 != null && imageBase64!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            base64Decode(imageBase64),
                            height: 100,
                            width: 100,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            color: Colors.white,
                            height: 100,
                            width: 100,
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    'Name: ${player['name']}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age: ${player['age']}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Score: ${player['total_score']}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
