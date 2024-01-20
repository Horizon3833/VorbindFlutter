import 'package:flutter/material.dart';
import 'package:vorbind/helpers/custom_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

void openProfileScreen(BuildContext context){
  Navigator.pushNamed(context, '/profile');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.darkGrey,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [ TextButton(child: const Icon(Icons.edit), onPressed: () => openProfileScreen(context)), ],
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
            subtitle:
                Text('Last message...'), // Replace with actual last message
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button tap
          // Open a new chat or perform other actions
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
