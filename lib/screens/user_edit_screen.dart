import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class UserEditScreen extends StatefulWidget {
  final int userId;
  const UserEditScreen({super.key, required this.userId});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _occupationController;
  late TextEditingController _bioController;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
    _bioController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUser(widget.userId);
    });
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!_isInit && userProvider.selectedUser != null) {
          final user = userProvider.selectedUser!;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _occupationController.text = user.occupation;
          _bioController.text = user.bio;
          _isInit = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Edit User')),
          body:
              userProvider.isLoading && userProvider.selectedUser == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _occupationController,
                            decoration: const InputDecoration(
                              labelText: 'Occupation',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) => value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                userProvider.isLoading
                                    ? null
                                    : () {
                                      if (_formKey.currentState!.validate()) {
                                        final updatedUser = User(
                                          id: widget.userId,
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          occupation:
                                              _occupationController.text,
                                          bio: _bioController.text,
                                        );
                                        userProvider.updateUser(updatedUser).then(
                                          (_) {
                                            if (userProvider.error == null) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'User updated successfully',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    userProvider.error!,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }
                                    },
                            child:
                                userProvider.isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
