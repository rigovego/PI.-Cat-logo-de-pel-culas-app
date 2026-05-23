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

class AppColors {
  static const fondo = Color(0xFF0E0B16);
  static const morado = Color(0xFF6C3DD9);
  static const moradoClaro = Color(0xFF9B7CFF);
  static const tarjeta = Color(0xFF1A1428);
  static const texto = Color(0xFFF5F2FF);
  static const textoSuave = Color(0xFFC9C1DD);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.fondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.morado,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.tarjeta,
          foregroundColor: AppColors.texto,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: AppColors.tarjeta.withOpacity(0.92),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          labelStyle: const TextStyle(color: AppColors.textoSuave),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.moradoClaro),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.morado,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.moradoClaro,
            side: const BorderSide(color: AppColors.moradoClaro),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const InicioPage(),
    );
  }
}

class FondoApp extends StatelessWidget {
  final Widget child;

  const FondoApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: AppColors.fondo.withOpacity(0.82),
          ),
        ),
        child,
      ],
    );
  }
}

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

// ===================== INICIO =====================

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoApp(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 110,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Catálogo de películas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texto,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Consulta, registra y administra películas desde una app conectada a Firebase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textoSuave),
                    ),
                    const SizedBox(height: 28),
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
      ),
    );
  }
}

// ===================== REGISTRO =====================

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

    setState(() => cargando = true);

    final existe = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: correo)
        .get();

    if (existe.docs.isNotEmpty) {
      setState(() => cargando = false);
      mostrarMensaje('Ese correo ya está registrado');
      return;
    }

    await FirebaseFirestore.instance.collection('usuarios').add({
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => cargando = false);

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
      body: FondoApp(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: correoController,
                        decoration: const InputDecoration(labelText: 'Correo'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration:
                        const InputDecoration(labelText: 'Contraseña'),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cargando ? null : registrarUsuario,
                          child: Text(cargando ? 'Registrando...' : 'Crear cuenta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== LOGIN =====================

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

    setState(() => cargando = true);

    final resultado = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('correo', isEqualTo: correo)
        .where('password', isEqualTo: password)
        .get();

    setState(() => cargando = false);

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
      body: FondoApp(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: correoController,
                        decoration: const InputDecoration(labelText: 'Correo'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration:
                        const InputDecoration(labelText: 'Contraseña'),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cargando ? null : iniciarSesion,
                          child: Text(cargando ? 'Ingresando...' : 'Entrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== CATÁLOGO =====================

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

  void cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const InicioPage()),
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
              if (valor == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              }


              if (valor == 'salir') {
                cerrarSesion();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'admin',
                child: Text('Administración'),
              ),
              PopupMenuItem(
                value: 'salir',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: FondoApp(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.tarjeta.withOpacity(0.82),
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
                    style: TextStyle(color: AppColors.textoSuave),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: peliculasRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar películas'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: pelicula.imagenUrl.isEmpty
                                    ? const Center(
                                  child: Icon(Icons.movie, size: 60),
                                )
                                    : Image.network(
                                  pelicula.imagenUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
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
      ),
    );
  }
}

// ===================== DETALLE =====================

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
      body: FondoApp(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: pelicula.imagenUrl.isEmpty
                  ? Container(
                height: 300,
                color: AppColors.tarjeta,
                child: const Icon(Icons.movie, size: 90),
              )
                  : Image.network(
                pelicula.imagenUrl,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: AppColors.tarjeta,
                    child: const Icon(Icons.broken_image, size: 80),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pelicula.sinopsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

// ===================== ADMINISTRACIÓN =====================

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
  String? peliculaEditandoId;

  String estadoHttp = 'Sin probar';
  bool httpOk = false;
  bool probandoHttp = false;

  Future<void> probarSolicitudHttp() async {
    setState(() {
      probandoHttp = true;
      estadoHttp = 'Probando...';
      httpOk = false;
    });

    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        setState(() {
          estadoHttp = 'OK';
          httpOk = true;
        });
      } else {
        setState(() {
          estadoHttp = 'Error';
          httpOk = false;
        });
      }
    } catch (e) {
      setState(() {
        estadoHttp = 'Error';
        httpOk = false;
      });
    } finally {
      setState(() {
        probandoHttp = false;
      });
    }
  }

  Future<void> guardarPelicula() async {
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

    setState(() => guardando = true);

    final datos = {
      'titulo': titulo,
      'anio': anio,
      'director': director,
      'genero': genero,
      'sinopsis': sinopsis,
      'imagenUrl': imagenUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (peliculaEditandoId == null) {
      await FirebaseFirestore.instance.collection('peliculas').add({
        ...datos,
        'createdAt': FieldValue.serverTimestamp(),
      });

      mostrarMensaje('Película agregada correctamente');
    } else {
      await FirebaseFirestore.instance
          .collection('peliculas')
          .doc(peliculaEditandoId)
          .update(datos);

      mostrarMensaje('Película actualizada correctamente');
    }

    limpiarFormulario();

    setState(() => guardando = false);
  }

  void cargarParaEditar(Pelicula pelicula) {
    setState(() {
      peliculaEditandoId = pelicula.id;
      tituloController.text = pelicula.titulo;
      anioController.text = pelicula.anio;
      directorController.text = pelicula.director;
      generoController.text = pelicula.genero;
      sinopsisController.text = pelicula.sinopsis;
      imagenController.text = pelicula.imagenUrl;
    });

    mostrarMensaje('Editando: ${pelicula.titulo}');
  }

  void cancelarEdicion() {
    limpiarFormulario();
    mostrarMensaje('Edición cancelada');
  }

  void limpiarFormulario() {
    setState(() {
      peliculaEditandoId = null;
      tituloController.clear();
      anioController.clear();
      directorController.clear();
      generoController.clear();
      sinopsisController.clear();
      imagenController.clear();
    });
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

    final estaEditando = peliculaEditandoId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
      ),
      body: FondoApp(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      estaEditando ? 'Editar película' : 'Agregar película',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        onPressed: guardando ? null : guardarPelicula,
                        icon: Icon(estaEditando ? Icons.save : Icons.add),
                        label: Text(
                          guardando
                              ? 'Guardando...'
                              : estaEditando
                              ? 'Guardar cambios'
                              : 'Agregar película',
                        ),
                      ),
                    ),
                    if (estaEditando) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: cancelarEdicion,
                          child: const Text('Cancelar edición'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Películas registradas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: probandoHttp ? null : probarSolicitudHttp,
                      child: Text(probandoHttp ? 'Probando...' : 'Probar HTTP'),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      httpOk ? Icons.check_circle : Icons.info_outline,
                      color: httpOk ? Colors.greenAccent : AppColors.textoSuave,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estadoHttp,
                      style: TextStyle(
                        color: httpOk ? Colors.greenAccent : AppColors.textoSuave,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pelicula.imagenUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                        ),
                        title: Text(pelicula.titulo),
                        subtitle: Text('${pelicula.anio} · ${pelicula.genero}'),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.moradoClaro,
                              ),
                              onPressed: () {
                                cargarParaEditar(pelicula);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                eliminarPelicula(pelicula.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
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
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}