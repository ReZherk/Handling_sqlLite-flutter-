# Guía detallada de SQLite en Flutter con `sqflite`

## Introducción

Este documento explica detalladamente el funcionamiento del código para manejar SQLite en una aplicación Flutter usando el paquete `sqflite`. Se analizará cada parte del código relacionada con SQLite y la gestión de rutas (`path`).

## Dependencias necesarias

Antes de utilizar SQLite en Flutter, es necesario agregar las siguientes dependencias en el archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.2.0 # Para manejar la base de datos SQLite
  path: ^1.8.0 # Para construir rutas de archivos de forma segura
```

Tras agregar estas dependencias, se deben instalar ejecutando:

```sh
flutter pub get
```

## Explicación del código

### 1. Importaciones

```dart
import 'package:path/path.dart';
import 'package:shopsqlite/models.dart';
import 'package:sqflite/sqflite.dart';
```

- `package:path/path.dart`: Proporciona funciones para manipular rutas de archivos.
- `package:shopsqlite/models.dart`: Importa la clase `CartItem` (suponiendo que es un modelo de datos).
- `package:sqflite/sqflite.dart`: Proporciona la funcionalidad de SQLite para Flutter.

### 2. Definición de la clase `ShopDatabase`

```dart
class ShopDatabase {
  static final ShopDatabase instance = ShopDatabase._init();
  static Database? _database;

  ShopDatabase._init();

  final String tableCartItems = 'cart_items';
```

- Se usa el **patrón Singleton** para asegurarse de que solo haya una instancia de `ShopDatabase`.
- `_database` almacena la instancia de la base de datos.
- `tableCartItems` contiene el nombre de la tabla de la base de datos.

### 3. Getter `database`

```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDB('shop.db');
  return _database!;
}
```

- Comprueba si la base de datos ya ha sido creada.
- Si no existe, llama a `_initDB('shop.db')` para inicializarla.
- Devuelve la instancia de la base de datos.

### 4. Inicialización de la base de datos (`_initDB`)

```dart
Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(path, version: 1, onCreate: _onCreateDB);
}
```

#### **Explicación**:

- `getDatabasesPath()`: Obtiene el directorio predeterminado donde se almacenan las bases de datos en el dispositivo.
- `join(dbPath, filePath)`: Usa la función `join` para combinar de manera segura la ruta base con el nombre del archivo de la base de datos (`shop.db`).
- `openDatabase(path, version: 1, onCreate: _onCreateDB)`: Abre la base de datos con versión específica. Si no existe, ejecuta la función `_onCreateDB` para crearla.

### 5. Creación de la tabla (`_onCreateDB`)

```dart
Future _onCreateDB(Database db, int version) async {
  await db.execute('''
  CREATE TABLE $tableCartItems(
  id INTEGER PRIMARY KEY,
  name TEXT,
  price INTEGER,
  quantity INTEGER
  )
  ''');
}
```

- `db.execute(...)`: Ejecuta una consulta SQL para crear una tabla con las siguientes columnas:
  - `id`: Identificador único (clave primaria).
  - `name`: Nombre del producto.
  - `price`: Precio del producto.
  - `quantity`: Cantidad disponible.

### 6. Insertar datos en la base de datos (`insert`)

```dart
Future<void> insert(CartItem item) async {
  final db = await instance.database;
  await db.insert(
    tableCartItems,
    item.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
```

- Obtiene la instancia de la base de datos llamando a `instance.database`.
- Inserta un nuevo registro en la tabla `cart_items` usando el método `insert()` de `sqflite`.
- `item.toMap()`: Convierte el objeto `CartItem` a un `Map<String, dynamic>` para que pueda insertarse en la base de datos.
- `conflictAlgorithm: ConflictAlgorithm.replace`: Especifica que si existe un registro con el mismo ID, se reemplazará con el nuevo.

### 7. Consultar todos los elementos (`getAllItems`)

```dart
Future<List<CartItem>> getAllItems() async {
  final db = await instance.database;
  final List<Map<String, dynamic>> maps = await db.query(tableCartItems);

  return List.generate(maps.length, (i) {
    return CartItem(
      id: maps[i]['id'],
      name: maps[i]['name'],
      price: maps[i]['price'],
      quantity: maps[i]['quantity'],
    );
  });
}
```

- Recupera todos los registros de la tabla `cart_items`.
- Convierte cada registro (representado como un `Map<String, dynamic>`) en un objeto `CartItem`.
- Devuelve una lista de objetos `CartItem`.

### 8. Eliminar elementos (`delete`)

```dart
Future<int> delete(int id) async {
  final db = await instance.database;
  return await db.delete(tableCartItems, where: "id = ?", whereArgs: [id]);
}
```

- Elimina un registro de la tabla `cart_items` basado en su ID.
- El parámetro `where` especifica la condición para la eliminación.
- El parámetro `whereArgs` proporciona los valores para los marcadores de posición (`?`) en la condición `where`.
- Retorna el número de filas afectadas.

### 9. Actualizar elementos (`update`)

```dart
Future<int> update(CartItem item) async {
  final db = await instance.database;
  return await db.update(
    tableCartItems,
    item.toMap(),
    where: "id=?",
    whereArgs: [item.id],
  );
}
```

- Actualiza un registro existente en la tabla `cart_items`.
- Se utiliza el ID del `CartItem` para identificar el registro a actualizar.
- El método `toMap()` convierte el objeto `CartItem` en un `Map<String, dynamic>` con los nuevos valores.
- Retorna el número de filas afectadas.

## **Resumen**

Este código implementa una base de datos SQLite en Flutter utilizando `sqflite`. Maneja:

- Creación de una base de datos con versión especificada.
- Creación de una tabla dentro de la base de datos.
- Inserción de datos con manejo de conflictos.
- Consulta de todos los registros.
- Eliminación de registros por ID.
- Actualización de registros existentes.
- Uso del patrón Singleton para gestionar la conexión a la base de datos.

Estas operaciones CRUD (Crear, Leer, Actualizar, Eliminar) proporcionan todas las funcionalidades básicas necesarias para manejar datos persistentes en una aplicación Flutter usando SQLite.
