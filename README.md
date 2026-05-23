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

### Evidencia de aplicación
Pantalla principal.
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/01147b30-53ab-4450-8b2f-7ab1fe147740" />
Pantalla de registro de usuario.
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/0eb87e7a-236d-4d99-9618-6b882d5fb30a" />
Pantalla de inicio de sesión
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/6568eb40-177d-4750-9eb3-dcff4f6a2bc0" />
Pantalla principal del catálogo
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/32e68602-f899-4f5f-b82c-559494b38493" />
Menú
<img width="492" height="147" alt="image" src="https://github.com/user-attachments/assets/4b98e3aa-3932-40db-af07-389f0624989a" />
Pantalla de administración, creación de registros nuevos y edición o elminación de las peliculas ya registradas
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/459641ae-2c1b-4eb3-8299-c73c1c97084b" />
Pantalla de edición de una pelicula
<img width="500" height="879" alt="image" src="https://github.com/user-attachments/assets/0b48abf5-7d13-4470-8f25-526cf5b0d8e8" />







