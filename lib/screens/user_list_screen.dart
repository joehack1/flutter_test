import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'user_edit_screen.dart';
import 'dart:developer' as dev; // For logging

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Users')),
          body: _buildBody(userProvider),
          floatingActionButton: FloatingActionButton(
            onPressed:
                userProvider.isLoading ? null : () => userProvider.fetchUsers(),
            tooltip: 'Refresh',
            child:
                userProvider.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.refresh),
          ),
        );
      },
    );
  }

  Widget _buildBody(UserProvider userProvider) {
    if (userProvider.isLoading && userProvider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userProvider.error != null) {
      return Center(child: Text('Error: ${userProvider.error}'));
    }
    if (userProvider.users.isEmpty) {
      return const Center(
        child: Text('No users found. Tap refresh to try again.'),
      );
    }

    // Log user data for debugging
    dev.log(
      'Users loaded: ${userProvider.users.map((u) => 'ID: ${u.id}, Name: ${u.name}').join(', ')}',
      name: 'UserListScreen',
    );

    return RefreshIndicator(
      onRefresh: userProvider.fetchUsers,
      child: ListView.separated(
        itemCount: userProvider.users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = userProvider.users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.occupation),
              trailing:
                  user.id != null
                      ? const Icon(Icons.edit, color: Colors.blue)
                      : const Icon(
                        Icons.error,
                        color: Colors.red,
                      ), // Visual cue for null ID
              onTap: () {
                if (user.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserEditScreen(userId: user.id!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot edit user: ID is missing'),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
