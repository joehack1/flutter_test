import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'user_edit_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Users'), elevation: 2),
          body: _buildBody(userProvider),
          floatingActionButton: FloatingActionButton(
            onPressed:
                userProvider.isLoading ? null : () => userProvider.fetchUsers(),
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

    if (userProvider.users.isEmpty) {
      return const Center(
        child: Text(
          'No users found. Tap refresh to try again.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

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
              trailing: const Icon(Icons.edit, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEditScreen(userId: user.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
