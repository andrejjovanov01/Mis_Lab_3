import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JokesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void addData(joke) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      CollectionReference jokes = FirebaseFirestore.instance.collection('jokes');
      await jokes.add({
        'joke': joke,
        'email': email,
      });
      print('Data added successfully!');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<String?> getBestJoke() async {
    try {
      CollectionReference jokes = FirebaseFirestore.instance.collection('jokes');
      QuerySnapshot querySnapshot = await jokes.get();
      Map<String, int> jokeFrequency = {};

      for (var doc in querySnapshot.docs) {
        String joke = doc['joke'];
        if (jokeFrequency.containsKey(joke)) {
          jokeFrequency[joke] = jokeFrequency[joke]! + 1;
        } else {
          jokeFrequency[joke] = 1;
        }
      }

      String? bestJoke;
      int maxFrequency = 0;
      for (var entry in jokeFrequency.entries) {
        if (entry.value > maxFrequency) {
          maxFrequency = entry.value;
          bestJoke = entry.key;
        }
      }

      return bestJoke;
    } catch (e) {
      print('Error getting best joke: $e');
      return null;
    }
  }

  Future<List<String>> getAllJokesForEmail(String email) async {
    try {
      CollectionReference jokes = FirebaseFirestore.instance.collection('jokes');
      QuerySnapshot querySnapshot = await jokes.where('email', isEqualTo: email).get();
      List<String> jokesList = [];

      for (var doc in querySnapshot.docs) {
        jokesList.add(doc['joke']);
      }

      return jokesList;
    } catch (e) {
      print('Error getting jokes for email: $e');
      return [];
    }
  }

}