import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatListScreen(),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with the actual number of chats
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Replace with user profile image
              child: Text('${index + 1}'),
            ),
            title: Text('Chat ${index + 1}'),
            subtitle: Text('Last message...'), // Replace with actual last message
            onTap: () {
              // Handle chat item tap
              // Navigate to the chat screen or perform other actions
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button tap
          // Open a new chat or perform other actions
        },
        child: Icon(Icons.message),
      ),
    );
  }
}