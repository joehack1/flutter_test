import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class UserEditScreen extends StatefulWidget {
  final int userId;

  UserEditScreen({required this.userId});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _occupationController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUser(widget.userId);
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.selectedUser != null && _nameController.text.isEmpty) {
      final user = userProvider.selectedUser!;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _occupationController.text = user.occupation;
      _bioController.text = user.bio;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit User')),
      body: userProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _occupationController,
                      decoration: InputDecoration(labelText: 'Occupation'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedUser = User(
                            id: widget.userId,
                            name: _nameController.text,
                            email: _emailController.text,
                            occupation: _occupationController.text,
                            bio: _bioController.text,
                          );
                          userProvider.updateUser(updatedUser).then((_) {
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}