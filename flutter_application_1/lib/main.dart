import 'package:flutter/material.dart';

// 1. Punto de entrada de la aplicación
void main() {
  runApp(const MyApp());
}

// 2. El widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Mesero',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Ocultamos la cinta de "DEBUG"
      debugShowCheckedModeBanner: false, 
      // Iniciamos en nuestro nuevo widget HomeScreen
      home: const HomeScreen(), 
    );
  }
}

// 3. Nuestra pantalla de inicio personalizada
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold es la estructura básica de una pantalla (fondo blanco, appbar, etc.)
    return Scaffold(
      // Usamos un Stack para poner widgets uno encima de otro (capas)
      body: Stack(
        // Hacemos que el Stack ocupe toda la pantalla
        fit: StackFit.expand, 
        children: [
          
          // --- CAPA 1: IMAGEN DE FONDO ---
          // Usamos Image.network para cargar una imagen desde internet.
          // Más adelante, puedes cambiar esto a Image.asset para usar
          // una imagen guardada dentro de tu app.
          Image.network(
            // URL de una imagen de un restaurante
            'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg', 
            // BoxFit.cover hace que la imagen cubra todo el espacio
            // disponible, recortándola si es necesario.
            fit: BoxFit.cover,
            // Agregamos un filtro de color para oscurecer la imagen
            // y hacer que el texto blanco resalte más.
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),

          // --- CAPA 2: CONTENIDO DE BIENVENIDA ---
          // Centramos el contenido en la pantalla
          Center(
            // Usamos una Columna para apilar el nombre y el saludo verticalmente
            child: Column(
              // Centramos la columna verticalmente
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
                
                // Un pequeño espacio entre los textos
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

