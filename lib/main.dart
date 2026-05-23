import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

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
      title: 'Catálogo de películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

// ======================================================
// MODELO SIMPLE
// ======================================================

class Pelicula {
  final String id;
  final String titulo;
  final String anio;
  final String director;
  final String genero;
  final String sinopsis;
  final String imagenUrl;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.anio,
    required this.director,
    required this.genero,
    required this.sinopsis,
    required this.imagenUrl,
  });

  factory Pelicula.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Pelicula(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      anio: data['anio'] ?? '',
      director: data['director'] ?? '',
      genero: data['genero'] ?? '',
      sinopsis: data['sinopsis'] ?? '',
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }
}

// ======================================================
// PANTALLA DE INICIO
// ======================================================

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de películas'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.movie_creation_outlined, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Consulta y administra un catálogo de películas conectado a Firebase.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('Ingresar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistroPage(),
                          ),
                        );
                      },
                      child: const Text('Registrarse'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REGISTRO SIMPLE CON FIRESTORE
// ======================================================

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (nombre.isEmpty || correo.isEmpty || password.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      cargando = true;
    });

    final existe = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: correo)
        .get();

    if (existe.docs.isNotEmpty) {
      setState(() {
        cargando = false;
      });
      mostrarMensaje('Ese correo ya está registrado');
      return;
    }

    await FirebaseFirestore.instance.collection('usuarios').add({
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      cargando = false;
    });

    mostrarMensaje('Usuario registrado correctamente');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogoPage(nombreUsuario: nombre),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : registrarUsuario,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Crear cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// LOGIN SIMPLE CONSULTANDO FIRESTORE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      mostrarMensaje('Escribe correo y contraseña');
      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: correo)
        .where('password', isEqualTo: password)
        .get();

    setState(() {
      cargando = false;
    });

    if (resultado.docs.isEmpty) {
      mostrarMensaje('Usuario o contraseña incorrectos');
      return;
    }

    final usuario = resultado.docs.first.data();
    final nombre = usuario['nombre'] ?? 'Usuario';

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogoPage(nombreUsuario: nombre),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando ? null : iniciarSesion,
                child: cargando
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// CATÁLOGO DE PELÍCULAS
// ======================================================

class CatalogoPage extends StatefulWidget {
  final String nombreUsuario;

  const CatalogoPage({
    super.key,
    required this.nombreUsuario,
  });

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  String mensajeHttp = 'Sin solicitud HTTP realizada';

  Future<void> probarSolicitudHttp() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      final data = jsonDecode(respuesta.body);

      setState(() {
        mensajeHttp = 'HTTP OK: ${data['title']}';
      });
    } else {
      setState(() {
        mensajeHttp = 'Error en solicitud HTTP';
      });
    }
  }

  void abrirAdministracion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminPage(),
      ),
    );
  }

  void cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const InicioPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final peliculasRef = FirebaseFirestore.instance
        .collection('peliculas')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'catalogo') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CatalogoPage(nombreUsuario: widget.nombreUsuario),
                  ),
                );
              }

              if (valor == 'admin') {
                abrirAdministracion();
              }

              if (valor == 'http') {
                probarSolicitudHttp();
              }

              if (valor == 'salir') {
                cerrarSesion();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'catalogo',
                child: Text('Catálogo de películas'),
              ),
              PopupMenuItem(
                value: 'admin',
                child: Text('Administración'),
              ),
              PopupMenuItem(
                value: 'http',
                child: Text('Probar solicitud HTTP'),
              ),
              PopupMenuItem(
                value: 'salir',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.deepPurple.withOpacity(0.08),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${widget.nombreUsuario}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona una película para ver su descripción.',
                ),
                const SizedBox(height: 8),
                Text(
                  mensajeHttp,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: peliculasRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error al cargar películas'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Todavía no hay películas.\nAgrega una desde Administración.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final pelicula = Pelicula.fromFirestore(docs[index]);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetallePeliculaPage(pelicula: pelicula),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: pelicula.imagenUrl.isEmpty
                                  ? Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.movie, size: 60),
                                ),
                              )
                                  : Image.network(
                                pelicula.imagenUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                pelicula.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// DETALLE DE PELÍCULA
// ======================================================

class DetallePeliculaPage extends StatelessWidget {
  final Pelicula pelicula;

  const DetallePeliculaPage({
    super.key,
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pelicula.titulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: pelicula.imagenUrl.isEmpty
                ? Container(
              height: 280,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.movie, size: 80),
              ),
            )
                : Image.network(
              pelicula.imagenUrl,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 80),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            pelicula.titulo,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          info('Año', pelicula.anio),
          info('Director', pelicula.director),
          info('Género', pelicula.genero),
          const SizedBox(height: 16),
          const Text(
            'Sinopsis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            pelicula.sinopsis,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget info(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$etiqueta: $valor',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

// ======================================================
// ADMINISTRACIÓN
// ======================================================

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final tituloController = TextEditingController();
  final anioController = TextEditingController();
  final directorController = TextEditingController();
  final generoController = TextEditingController();
  final sinopsisController = TextEditingController();
  final imagenController = TextEditingController();

  bool guardando = false;

  Future<void> agregarPelicula() async {
    final titulo = tituloController.text.trim();
    final anio = anioController.text.trim();
    final director = directorController.text.trim();
    final genero = generoController.text.trim();
    final sinopsis = sinopsisController.text.trim();
    final imagenUrl = imagenController.text.trim();

    if (titulo.isEmpty ||
        anio.isEmpty ||
        director.isEmpty ||
        genero.isEmpty ||
        sinopsis.isEmpty ||
        imagenUrl.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      guardando = true;
    });

    await FirebaseFirestore.instance.collection('peliculas').add({
      'titulo': titulo,
      'anio': anio,
      'director': director,
      'genero': genero,
      'sinopsis': sinopsis,
      'imagenUrl': imagenUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    tituloController.clear();
    anioController.clear();
    directorController.clear();
    generoController.clear();
    sinopsisController.clear();
    imagenController.clear();

    setState(() {
      guardando = false;
    });

    mostrarMensaje('Película agregada correctamente');
  }

  Future<void> eliminarPelicula(String id) async {
    await FirebaseFirestore.instance.collection('peliculas').doc(id).delete();
    mostrarMensaje('Película eliminada');
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    tituloController.dispose();
    anioController.dispose();
    directorController.dispose();
    generoController.dispose();
    sinopsisController.dispose();
    imagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peliculasRef = FirebaseFirestore.instance
        .collection('peliculas')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Agregar película',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          campo(tituloController, 'Título'),
          campo(anioController, 'Año'),
          campo(directorController, 'Director'),
          campo(generoController, 'Género'),
          campo(sinopsisController, 'Sinopsis', maxLines: 3),
          campo(imagenController, 'URL de imagen'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: guardando ? null : agregarPelicula,
              icon: const Icon(Icons.add),
              label: guardando
                  ? const Text('Guardando...')
                  : const Text('Agregar película'),
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Películas registradas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: peliculasRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error al cargar películas');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Text('No hay películas registradas');
              }

              return Column(
                children: docs.map((doc) {
                  final pelicula = Pelicula.fromFirestore(doc);

                  return Card(
                    child: ListTile(
                      leading: pelicula.imagenUrl.isEmpty
                          ? const Icon(Icons.movie)
                          : Image.network(
                        pelicula.imagenUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                      title: Text(pelicula.titulo),
                      subtitle: Text('${pelicula.anio} · ${pelicula.genero}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          eliminarPelicula(pelicula.id);
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget campo(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}