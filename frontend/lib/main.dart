import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Task {
  final int id;
  final String title;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'] ?? false,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController controller = TextEditingController();

  List<Task> todos = [];
  bool isLoading = true;

  // Replace this with your laptop's real local IP address
  // Example: http://192.168.1.23:5000
  static const String baseUrl = 'http://192.168.8.191:5000';

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tasks'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          todos = data.map((item) => Task.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Fetch failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Fetch error: $e');
    }
  }

  Future<void> addTodo() async {
    final title = controller.text.trim();
    if (title.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 201) {
        controller.clear();
        await fetchTodos();
      } else {
        debugPrint('Add failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/tasks/$id'),
      );

      if (response.statusCode == 200) {
        await fetchTodos();
      } else {
        debugPrint('Delete failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> toggleTodo(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'is_done': !task.isDone}),
      );

      if (response.statusCode == 200) {
        await fetchTodos();
      } else {
        debugPrint('Update failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Todo App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a task...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => addTodo(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addTodo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : todos.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks yet 👀',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final task = todos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isDone,
                                onChanged: (_) => toggleTodo(task),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteTodo(task.id),
                              ),
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
