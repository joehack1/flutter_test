import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class UserEditScreen extends StatefulWidget {
  final String userId;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _occupationController = TextEditingController();
    _bioController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.users.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => User(
          id: widget.userId,
          name: 'Unknown',
          email: 'No email',
          occupation: 'No occupation',
          bio: 'User data unavailable',
        ),
      );
      userProvider.setSelectedUser(user);
      _nameController.text = user.name;
      _emailController.text = user.email;
      _occupationController.text = user.occupation;
      _bioController.text = user.bio;
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
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: Colors.blueAccent)),
          );
        }
        if (userProvider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        if (userProvider.selectedUser == null) {
          return const Scaffold(
            body: Center(
              child: Text('User not found',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit User'),
            elevation: 0,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Details',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Name',
                          icon: Icons.person,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter an email' : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _occupationController,
                          label: 'Occupation',
                          icon: Icons.work,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter an occupation' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final updatedUser = User(
                                  id: userProvider.selectedUser!.id,
                                  name: _nameController.text,
                                  email: _emailController.text,
                                  occupation: _occupationController.text,
                                  bio: _bioController.text,
                                );
                                userProvider.updateUser(updatedUser).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        userProvider.error == null
                                            ? 'User updated successfully'
                                            : 'Error: ${userProvider.error}',
                                      ),
                                      backgroundColor:
                                          userProvider.error == null
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  );
                                  if (userProvider.error == null) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
