import 'package:flutter/material.dart';
// 1. Importamos los paquetes que necesitaremos
import 'dart:convert'; // Para jsonDecode (convertir JSON a Mapa)
import 'package:http/http.dart' as http; // Para hacer las peticiones HTTP

// --- Tu código existente (main y MyApp) ---

// Punto de entrada de la aplicación
void main() {
  runApp(const MyApp());
}

// El widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Mesero',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Damos un estilo al nuevo botón que vamos a agregar
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // Ocultamos la cinta de "DEBUG"
      debugShowCheckedModeBanner: false,
      // Iniciamos en nuestro widget HomeScreen
      home: const HomeScreen(),
    );
  }
}

// --- Tu pantalla de inicio (MODIFICADA) ---
// Este es el código que tú escribiste, con solo un widget añadido
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- CAPA 1: IMAGEN DE FONDO ---
          Image.network(
            'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),

          // --- CAPA 2: CONTENIDO DE BIENVENIDA ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Requisito: Nombre de la Aplicación
                Text(
                  'App de Mesero',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Requisito: Mensaje de Bienvenida
                Text(
                  '¡Bienvenido!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                // --- ¡NUEVO WIDGET AÑADIDO! ---
                // Agregamos un espacio y un botón para ir a la nueva pantalla
                const SizedBox(height: 50),
                ElevatedButton(
                  child: const Text('Consultar Pokémon'),
                  onPressed: () {
                    // Navegamos a la nueva pantalla que creamos abajo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PokemonScreen()),
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

// -------------------------------------------------------------------
// --- INICIO DEL NUEVO CÓDIGO PARA LA PETICIÓN HTTP ---
// -------------------------------------------------------------------

// 4. Modelo de Datos (Clase Pokémon)
// Esto define la "plantilla" de los datos que queremos
// sacar del JSON.
//
// El JSON de PokeAPI es gigante, pero solo nos interesan 3 campos:
// {
//   "id": 132,
//   "name": "ditto",
//   "sprites": {
//     "front_default": "https://url-de-la-imagen.png"
//   }
//   ...muchos otros campos que ignoraremos...
// }

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Este es un "constructor de fábrica"
  // Recibe un Mapa (el JSON decodificado) y crea un objeto Pokemon.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Hacemos un chequeo por si 'front_default' es nulo
    final imageUrl = json['sprites']?['front_default'] ?? 
        'https://placehold.co/150x150/png?text=No+Image'; // Una imagen por defecto

    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: imageUrl,
    );
  }
}

// 5. Función de Petición HTTP
// Esta es la función asíncrona que realmente hace la llamada
// a la API. Devuelve un "Future" (una promesa) de un objeto Pokemon.

Future<Pokemon> fetchPokemon() async {
  // 1. Hacemos la petición GET a la URL de la API.
  //    Vamos a pedir los datos de Ditto (ID 132)
  final response = await http
      .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/ditto'));

  // 2. Verificamos si la respuesta fue exitosa (código 200)
  if (response.statusCode == 200) {
    // 3. Si fue OK, convertimos el texto (response.body) de JSON
    //    a un Mapa de Dart usando jsonDecode.
    // 4. Creamos un objeto Pokemon usando nuestro factory .fromJson
    return Pokemon.fromJson(jsonDecode(response.body));
  } else {
    // 5. Si el servidor no respondió OK, lanzamos un error.
    throw Exception('Falló al cargar el Pokémon (Código: ${response.statusCode})');
  }
}

// 6. Nueva Pantalla para mostrar los datos
// Usamos un StatefulWidget porque los datos (el Future)
// cambiarán/llegarán *después* de que la pantalla se dibuje.
class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  // Creamos una variable para guardar nuestro "Future".
  // Es 'late' porque la inicializaremos en initState.
  late Future<Pokemon> futurePokemon;

  @override
  void initState() {
    super.initState();
    // 3. Llamamos a la función de la API aquí.
    //    Esto hace que la petición se inicie UNA SOLA VEZ
    //    cuando la pantalla se carga.
    futurePokemon = fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos desde Internet (PokeAPI)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200], // Un fondo suave
      // 4. Usamos un FutureBuilder:
      // Este widget es la clave. Se "suscribe" a nuestro Future
      // y se redibuja a sí mismo según el estado del Future.
      body: Center(
        child: FutureBuilder<Pokemon>(
          future: futurePokemon, // Le decimos qué Future "escuchar"
          builder: (context, snapshot) {
            
            

            // CASO 1: El Future todavía está cargando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Muestra un spinner
            }
            // CASO 2: El Future terminó con un error
            else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ); // Muestra el error
            }
            // CASO 3: El Future terminó exitosamente y tiene datos
            else if (snapshot.hasData) {
              // ¡Tenemos datos! snapshot.data contiene nuestro objeto Pokemon
              return Card(
                elevation: 6,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Que la tarjeta se ajuste
                    children: [
                      // Damos un borde y sombra a la imagen
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        // Usamos Image.network para mostrar la imagen desde la URL
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          // Mostramos un 'cargando' para la imagen misma
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              height: 150,
                              width: 150,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mostramos el nombre
                      Text(
                        // Capitalizamos el nombre (Ditto)
                        snapshot.data!.name[0].toUpperCase() +
                            snapshot.data!.name.substring(1),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      // Mostramos el ID
                      Text(
                        'ID: ${snapshot.data!.id}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[700]
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // CASO 4: (Por si acaso) El Future terminó sin datos y sin error
            else {
              return const Text('No se encontraron datos.');
            }
          },
        ),
      ),
    );
  }
}