import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- IMPORTACIONES DE FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ¡NUEVO! Para la base de datos
import 'firebase_options.dart';

// 1. Punto de entrada
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Mesero',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- FUNCIÓN DE BASE DE DATOS ---
  // Esta función guarda una venta ficticia en Firestore
  void _registrarVentaPrueba(BuildContext context) {
    // 1. Obtenemos la referencia a la colección 'ventas'
    CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');

    // 2. Agregamos un documento nuevo
    ventas.add({
      'mesa': 'Mesa ${DateTime.now().second}', // Mesa aleatoria basada en segundos
      'monto': 150.00, // Un monto fijo por ahora
      'fecha': DateTime.now(), // La hora actual
    }).then((value) {
      // Si sale bien:
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Venta guardada en Firebase!'))
      );
    }).catchError((error) {
      // Si falla:
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error'))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- CAPA 1: FONDO ---
          Image.network(
            'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6), // Un poco más oscuro para leer mejor
            colorBlendMode: BlendMode.darken,
          ),

          // --- CAPA 2: CONTENIDO ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'App de Mesero',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 24, fontStyle: FontStyle.italic, color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- WIDGET DE BASE DE DATOS (LECTURA) ---
                // StreamBuilder escucha cambios en tiempo real de Firestore
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('ventas').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error en BD', style: TextStyle(color: Colors.red));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Colors.white);
                    }
                    
                    // Obtenemos el número de documentos (ventas)
                    final int cantidadVentas = snapshot.data!.docs.length;

                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white30)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Ventas Registradas en Nube:',
                            style: TextStyle(color: Colors.orange[300], fontSize: 14),
                          ),
                          Text(
                            '$cantidadVentas', // ¡Este número cambia solo!
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // --- BOTÓN 1: ESCRIBIR EN BASE DE DATOS ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Registrar Venta (BD)'),
                  onPressed: () => _registrarVentaPrueba(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.orange[800], // Color diferente para distinguir
                  ),
                ),

                const SizedBox(height: 20),

                // --- BOTÓN 2: API EXTERNA (POKEAPI) ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Consultar Pokémon (HTTP)'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PokemonScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CÓDIGO DE POKEAPI (Igual que antes) ---
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({required this.id, required this.name, required this.imageUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['sprites']?['front_default'] ?? 
        'https://placehold.co/150x150/png?text=No+Image';
    return Pokemon(id: json['id'], name: json['name'], imageUrl: imageUrl);
  }
}

Future<Pokemon> fetchPokemon() async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/ditto'));
  if (response.statusCode == 200) {
    return Pokemon.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Falló al cargar el Pokémon');
  }
}

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  late Future<Pokemon> futurePokemon;

  @override
  void initState() {
    super.initState();
    futurePokemon = fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos desde Internet')),
      body: Center(
        child: FutureBuilder<Pokemon>(
          future: futurePokemon,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(snapshot.data!.imageUrl),
                  Text(snapshot.data!.name, style: const TextStyle(fontSize: 30)),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}