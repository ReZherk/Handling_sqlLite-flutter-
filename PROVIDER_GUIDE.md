# Guía completa de Provider en Flutter

## Introducción

Provider es una de las soluciones más populares para la gestión de estado en Flutter. Está construido sobre InheritedWidget, pero simplifica su uso y reduce la cantidad de código repetitivo. Esta guía te enseñará cómo implementar Provider en tus aplicaciones Flutter desde cero, siguiendo las mejores prácticas.

## Instalación

Agrega Provider a tu proyecto añadiendo la dependencia en tu archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5 # Usa la versión más reciente
```

Luego ejecuta:

```bash
flutter pub get
```

## Conceptos básicos

Provider se basa en tres conceptos principales:

1. **ChangeNotifier**: Una clase que proporciona notificaciones a sus oyentes cuando cambia.
2. **ChangeNotifierProvider**: Un widget que crea y proporciona una instancia de ChangeNotifier a sus descendientes.
3. **Consumer/Provider.of**: Widgets o métodos para acceder a los datos proporcionados.

## Implementación paso a paso

### 1. Crear un modelo (ChangeNotifier)

Primero, define tu modelo extendiendo `ChangeNotifier`:

```dart
import 'package:flutter/foundation.dart';

class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();  // Notifica a los widgets que están escuchando
  }
}
```

### 2. Proporcionar el modelo

Envuelve tu widget principal con `ChangeNotifierProvider`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Demo',
      home: MyHomePage(),
    );
  }
}
```

### 3. Consumir el modelo

Existen tres formas principales de acceder a los datos:

#### Usando Consumer

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Provider Demo')),
      body: Center(
        child: Consumer<CounterModel>(
          builder: (context, counter, child) {
            return Text(
              'Contador: ${counter.count}',
              style: TextStyle(fontSize: 24),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Accedemos al modelo y llamamos al método increment
          Provider.of<CounterModel>(context, listen: false).increment();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### Usando Provider.of con escucha

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<CounterModel>(context);
    return Text(
      'Contador: ${counter.count}',
      style: TextStyle(fontSize: 24),
    );
  }
}
```

#### Usando Provider.of sin escucha (solo para acciones)

```dart
FloatingActionButton(
  onPressed: () {
    Provider.of<CounterModel>(context, listen: false).increment();
  },
  child: Icon(Icons.add),
)
```

## Casos de uso avanzados

### Múltiples providers

Si necesitas proporcionar varios modelos, usa `MultiProvider`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => CounterModel()),
    ChangeNotifierProvider(create: (context) => ShoppingCartModel()),
    ChangeNotifierProvider(create: (context) => UserModel()),
  ],
  child: MyApp(),
)
```

### Provider dependiente

Si un provider depende de otro:

```dart
ChangeNotifierProxyProvider<UserModel, CartModel>(
  create: (context) => CartModel(),
  update: (context, user, previousCart) =>
      previousCart!..updateUser(user),
)
```

### Provider con valor inicial

```dart
ChangeNotifierProvider.value(
  value: CounterModel(),
  child: SomeWidget(),
)
```

## Buenas prácticas

### 1. Arquitectura recomendada

Organiza tu código siguiendo una arquitectura clara:

```
lib/
├── main.dart
├── models/
│   ├── counter_model.dart
│   └── user_model.dart
├── providers/
│   └── providers.dart
├── screens/
│   ├── home_screen.dart
│   └── settings_screen.dart
└── widgets/
    └── counter_widget.dart
```

### 2. Separación de responsabilidades

- **Models**: Contienen la lógica de negocio y los datos.
- **Providers**: Configuración de providers.
- **Screens**: Páginas completas de la aplicación.
- **Widgets**: Componentes reutilizables.

### 3. Cuándo usar listen: false

- Usa `listen: false` cuando solo necesites llamar métodos en el provider (acciones) sin necesidad de reconstruir el widget.
- Usa `listen: true` (por defecto) o `Consumer` cuando necesites que el widget se reconstruya cuando cambien los datos.

### 4. Optimización de rendimiento

- Usa `Consumer` con el parámetro `child` para partes del widget que no necesitan reconstruirse:

```dart
Consumer<CounterModel>(
  builder: (context, counter, child) {
    return Column(
      children: [
        Text('Contador: ${counter.count}'),
        child!, // Esta parte no se reconstruye cuando cambia el contador
      ],
    );
  },
  child: ExpensiveWidget(), // Este widget no se reconstruye
)
```

- Usa `Selector` para reconstruir solo cuando cambien propiedades específicas:

```dart
Selector<UserModel, String>(
  selector: (context, userModel) => userModel.name,
  builder: (context, name, child) {
    return Text('Nombre: $name');
  },
)
```

### 5. Inicialización y disposición adecuadas

- Inicializa recursos en el constructor del modelo.
- Libera recursos en el método `dispose()`:

```dart
class ApiModel extends ChangeNotifier {
  HttpClient? _client;

  ApiModel() {
    _client = HttpClient();
    // Inicialización
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }
}
```

## Ejemplo completo: Lista de tareas

Veamos un ejemplo más completo de una aplicación de lista de tareas:

### Modelo

```dart
// task_model.dart
import 'package:flutter/foundation.dart';

class Task {
  final String id;
  final String title;
  bool completed;

  Task({required this.id, required this.title, this.completed = false});
}

class TaskModel extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get completedTasks =>
      _tasks.where((task) => task.completed).toList();

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.completed).toList();

  void addTask(String title) {
    final task = Task(
      id: DateTime.now().toString(),
      title: title,
    );
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].completed = !_tasks[taskIndex].completed;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
```

### Vista principal

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/task_model.dart';
import 'screens/task_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskScreen(),
    );
  }
}
```

### Pantalla de tareas

```dart
// task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../widgets/task_list.dart';
import '../widgets/new_task_form.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Tareas')),
      body: Column(
        children: [
          NewTaskForm(),
          Expanded(
            child: Consumer<TaskModel>(
              builder: (context, taskModel, child) {
                return DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Todas (${taskModel.tasks.length})'),
                          Tab(text: 'Pendientes (${taskModel.pendingTasks.length})'),
                          Tab(text: 'Completadas (${taskModel.completedTasks.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            TaskList(tasks: taskModel.tasks),
                            TaskList(tasks: taskModel.pendingTasks),
                            TaskList(tasks: taskModel.completedTasks),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Widgets

```dart
// new_task_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';

class NewTaskForm extends StatefulWidget {
  @override
  _NewTaskFormState createState() => _NewTaskFormState();
}

class _NewTaskFormState extends State<NewTaskForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _addTask(),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addTask,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      Provider.of<TaskModel>(context, listen: false).addTask(_controller.text);
      _controller.clear();
    }
  }
}

// task_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return tasks.isEmpty
        ? Center(child: Text('No hay tareas'))
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (_) {
                    Provider.of<TaskModel>(context, listen: false)
                        .toggleTask(task.id);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Provider.of<TaskModel>(context, listen: false)
                        .deleteTask(task.id);
                  },
                ),
              );
            },
          );
  }
}
```

## Solución de problemas comunes

### 1. Error: Could not find the correct Provider<T>

Este error ocurre cuando intentas acceder a un Provider que no está disponible en el árbol de widgets.

**Solución**: Asegúrate de que el widget esté por debajo del Provider en el árbol de widgets.

### 2. No se actualizan los widgets

**Posibles causas**:

- Olvidaste llamar a `notifyListeners()`
- Estás usando `listen: false` cuando necesitas reconstruir el widget

**Solución**: Asegúrate de llamar a `notifyListeners()` después de cada cambio de estado y usa `Consumer` o `Provider.of` con `listen: true` para los widgets que necesitan reconstruirse.

### 3. Provider usado después de dispose()

**Solución**: Verifica que no estés intentando acceder o modificar un Provider después de que el widget ha sido eliminado.

## Conclusión

Provider es una solución eficiente y fácil de usar para la gestión de estado en Flutter. Siguiendo estas buenas prácticas y patrones, puedes crear aplicaciones bien estructuradas y mantenibles. Recuerda:

1. Mantén la lógica de negocio en tus modelos (`ChangeNotifier`)
2. Proporciona los modelos lo más alto posible en el árbol de widgets
3. Consume los modelos de forma eficiente con `Consumer` o `Provider.of`
4. Optimiza el rendimiento usando `listen: false` cuando sea apropiado
5. Organiza tu código siguiendo una arquitectura clara
