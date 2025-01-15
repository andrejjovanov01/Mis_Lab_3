import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/auth_screen.dart';
import 'package:flutter_application_2/screens/best_joke_screen.dart';
import 'package:flutter_application_2/screens/favorites_screen.dart';
import 'package:flutter_application_2/services/jokes.dart';
import 'package:flutter_application_2/static_db.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter widgets are initialized before making async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,


  );
  final jokesService = JokesService();
  print(await jokesService.getBestJoke());


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Jokes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: JokesHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JokesHomeScreen extends StatefulWidget {
  const JokesHomeScreen({super.key});

  @override
  _JokesHomeScreenState createState() => _JokesHomeScreenState();
}

class _JokesHomeScreenState extends State<JokesHomeScreen> {
  List<String> jokeTypes = [];
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    fetchJokeTypes();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('user_email');
    });
  }

  Future<void> fetchJokeTypes() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/types'));
    if (response.statusCode == 200) {
      setState(() {
        jokeTypes = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load joke types');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Joke Types'),
            if (_email != null) Text(_email!, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () async {
              final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/random_joke'));
              if (response.statusCode == 200) {
                final joke = json.decode(response.body);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RandomJokeScreen(joke: joke),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.star   ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BestJokeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: jokeTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: jokeTypes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(jokeTypes[index], style: const TextStyle(fontSize: 18.0)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JokesByTypeScreen(type: jokeTypes[index]),
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

class JokesByTypeScreen extends StatefulWidget {
  final String type;
  const JokesByTypeScreen({super.key, required this.type});

  @override
  _JokesByTypeScreenState createState() => _JokesByTypeScreenState();
}

class _JokesByTypeScreenState extends State<JokesByTypeScreen> {
  List jokes = [];
  final jokesService = JokesService();

  @override
  void initState() {
    super.initState();
    fetchJokesByType();
  }

  Future<void> fetchJokesByType() async {
    final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/jokes/${widget.type}/ten'));
    if (response.statusCode == 200) {
      setState(() {
        jokes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load jokes of type ${widget.type}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.type} Jokes')),
      body: jokes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: jokes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(jokes[index]['setup'], style: const TextStyle(fontSize: 16.0)),
              subtitle: Text(jokes[index]['punchline'], style: const TextStyle(fontSize: 14.0)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.grey,
                onPressed: () {
                  jokesService.addData(jokes[index]['punchline']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class RandomJokeScreen extends StatelessWidget {
  final Map joke;
  const RandomJokeScreen({super.key, required this.joke});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Random Joke of the Day')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(joke['setup'], style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 20.0),
              Text(joke['punchline'], style: const TextStyle(fontSize: 16.0), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}