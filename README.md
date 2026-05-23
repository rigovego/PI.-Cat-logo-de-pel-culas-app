# PI. Catálogo de películas app

**Nombre:** Rigoberto Velasquez.
**Materia:** Diseño de aplicaciones móviles  
**Actividad:** Producto integrador - Catálogo de películas  
**Proyecto:** Aplicación móvil con Flutter y Firebase

## Descripción del proyecto

Esta aplicación móvil fue desarrollada como producto integrador de la materia de Diseño de aplicaciones móviles. Su objetivo es permitir al usuario visualizar un catálogo de películas, consultar la información detallada de cada título y administrar los registros desde una pantalla interna.

La app cuenta con una pantalla de inicio, registro e inicio de sesión simple, catálogo de películas, pantalla de detalle y una sección de administración donde se pueden agregar, editar y eliminar películas. Todos los cambios realizados se guardan directamente en una base de datos en Firebase.

## Funcionalidades principales

- Pantalla de bienvenida.
- Registro simple de usuarios.
- Inicio de sesión básico.
- Visualización de catálogo de películas.
- Consulta de detalle por película.
- Administración de películas.
- Alta de nuevas películas.
- Edición de películas existentes.
- Eliminación de películas del catálogo.
- Guardado de datos en Firebase Cloud Firestore.
- Prueba de solicitud HTTP desde la pantalla de administración.
- Uso de imágenes por URL para mostrar referencias visuales de las películas.
- Personalización visual con logo y fondo propio.

## Datos registrados por película

Cada película contiene los siguientes campos:

- Título
- Año
- Director
- Género
- Sinopsis
- Imagen de referencia mediante URL

## Tecnologías utilizadas

- **Flutter:** Framework utilizado para desarrollar la aplicación móvil.
- **Dart:** Lenguaje de programación principal del proyecto.
- **Firebase:** Plataforma utilizada como servicio backend.
- **Cloud Firestore:** Base de datos NoSQL utilizada para guardar usuarios y películas.
- **HTTP package:** Paquete utilizado para realizar una solicitud HTTP de prueba.
- **GitHub:** Control de versiones y repositorio del proyecto.

## Estructura general de la aplicación

La aplicación está organizada en las siguientes pantallas:

1. **Inicio:** muestra la bienvenida y permite elegir entre ingresar o registrarse.
2. **Registro:** permite crear un usuario simple y guardarlo en Firestore.
3. **Login:** permite ingresar con un usuario previamente registrado.
4. **Catálogo:** muestra las películas registradas con su título e imagen.
5. **Detalle:** muestra la información completa de la película seleccionada.
6. **Administración:** permite agregar, editar y eliminar películas.

## Base de datos

El proyecto utiliza Cloud Firestore con dos colecciones principales:

### Colección `usuarios`

Guarda los usuarios registrados en la aplicación.

Campos:

- `nombre`
- `correo`
- `password`
- `createdAt`

### Colección `peliculas`

Guarda las películas disponibles en el catálogo.

Campos:

- `titulo`
- `anio`
- `director`
- `genero`
- `sinopsis`
- `imagenUrl`
- `createdAt`
- `updatedAt`

