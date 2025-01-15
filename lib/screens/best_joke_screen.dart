import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/jokes.dart';

class BestJokeScreen extends StatefulWidget {
  const BestJokeScreen({super.key});

  @override
  _BestJokeState createState() => _BestJokeState();
}

class _BestJokeState extends State<BestJokeScreen> {
  final JokesService _jokesService = JokesService();
  String? _bestJoke;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBestJoke();
  }

  Future<void> _fetchBestJoke() async {
    try {
      _bestJoke = await _jokesService.getBestJoke();
    } catch (e) {
      print('Error fetching best joke: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Joke'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JokesHomeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bestJoke == null
          ? const Center(child: Text('No best joke found.'))
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _bestJoke!,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}