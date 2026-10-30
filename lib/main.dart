import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pokemon_model.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

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
  final TextEditingController nameController = TextEditingController();

  Pokemon? pokemon;
  bool isLoading = false;
  String? errorMessage;

  Future<void> searchPokemon() async {
    String name = nameController.text.trim().toLowerCase();

    if (name.isEmpty || isLoading) return;

    setState(() {
      isLoading = true;
      pokemon = null;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/$name',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 404) {
        throw Exception('Pokémon not found.');
      }

      if (response.statusCode != 200) {
        throw Exception('Something went wrong. Try again.');
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final result = Pokemon.fromJson(data);

      if (!mounted) return;

      setState(() {
        pokemon = result;
      });
    } on SocketException {
      showError('No internet connection.');
    } on TimeoutException {
      showError('Request timed out. Try again.');
    } on FormatException {
      showError('Invalid Pokémon information.');
    } catch (e) {
      showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showError(String message) {
    if (!mounted) return;

    setState(() {
      errorMessage = message;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
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
              controller: nameController,
              onSubmitted: (_) => searchPokemon(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : searchPokemon,
                child: const Text('Search'),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            if (pokemon != null)
              buildPokemonDetails(pokemon!),
          ],
        ),
      ),
    );
  }

  Widget buildPokemonDetails(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pokemon.image.isNotEmpty)
          Center(
            child: Image.network(
              pokemon.image,
              height: 180,
            ),
          ),

        Center(
          child: Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Divider(height: 28),

        detailRow('ID', pokemon.id.toString()),
        detailRow('Height', pokemon.height.toString()),
        detailRow('Weight', pokemon.weight.toString()),

        const SizedBox(height: 12),

        const Text(
          'Abilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(pokemon.abilities.join(', ')),

        const SizedBox(height: 12),

        const Text(
          'Types',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(pokemon.types.join(', ')),
      ],
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}