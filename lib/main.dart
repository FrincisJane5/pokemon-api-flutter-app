
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic>? pokemon;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> searchPokemon() async {
    String name = _controller.text.trim().toLowerCase();

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a Pokémon name.';
        pokemon = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      pokemon = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pokemon = data;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Pokémon not found. Please try another name.';
        });
      } else {
        setState(() {
          errorMessage = 'Something went wrong. Please try again.';
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'No internet connection. Please check your network.';
      });
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
      });
    } on FormatException {
      setState(() {
        errorMessage = 'Invalid data received from the server.';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pokémon Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (!isLoading) searchPokemon();
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: isLoading ? null : searchPokemon,
              child: const Text('Search'),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),

            if (pokemon != null) ...[
              Center(
                child: Image.network(
                  pokemon!['sprites']['front_default'] ?? '',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Image not available');
                  },
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Name: ${pokemon!['name'].toString().toUpperCase()}',
                style: const TextStyle(fontSize: 18),
              ),

              Text('ID: ${pokemon!['id']}'),

              Text('Height: ${pokemon!['height']}'),

              Text('Weight: ${pokemon!['weight']}'),

              const SizedBox(height: 10),

              const Text(
                'Abilities:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              ...((pokemon!['abilities'] as List).map((item) {
                return Text('- ${item['ability']['name']}');
              })),

              const SizedBox(height: 10),

              const Text(
                'Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              ...((pokemon!['types'] as List).map((item) {
                return Text('- ${item['type']['name']}');
              })),
            ],
          ],
        ),
      ),
    );
  }
}
