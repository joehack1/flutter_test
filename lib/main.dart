import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// User Model (simplified for this example)
class User {
  final int id;
  final String name;
  final String email;
  final String occupation;
  final String bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.occupation,
    required this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      occupation: json['occupation'],
      bio: json['bio'],
    );
  }
}

// User Provider (simplified for demo purposes)
class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  // Mock fetch users (replace with real API call later)
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    _users = [
      User(id: 1, name: "Barret", email: "bwallbutton0@salon.com", occupation: "Engineer", bio: "Lorem ipsum"),
      User(id: 2, name: "Alice", email: "alice@example.com", occupation: "Designer", bio: "Dolor sit amet"),
    ];
    _isLoading = false;
    notifyListeners();
  }
}

// Main App
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frontend Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Frontend Test Home'),
    );
  }
}

// Home Page (combines counter and user list)
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text('User List:'),
            userProvider.isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: userProvider.users.length,
                      itemBuilder: (context, index) {
                        final user = userProvider.users[index];
                        return ListTile(
                          title: Text(user.name),
                          subtitle: Text(user.occupation),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => userProvider.fetchUsers(),
            tooltip: 'Refresh Users',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}