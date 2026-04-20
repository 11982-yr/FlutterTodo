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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
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
  final TextEditingController _controller = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = true;

static const String baseUrl = 'http://10.61.11.171:5000';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tasks'));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _tasks = data.map((item) => Task.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint('Fetch failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Fetch error: $e');
    }
  }

  Future<void> addTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await fetchTasks();
      } else {
        debugPrint('Add failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/tasks/$id'),
      );

      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        debugPrint('Delete failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> toggleTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'is_done': !task.isDone}),
      );

      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        debugPrint('Update failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDay = days[DateTime.now().weekday - 1];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Todo App"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Add a new task...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => addTask(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.deepPurple,
                      size: 32,
                    ),
                    onPressed: addTask,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentDay,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(
                          child: Text(
                            "No tasks yet 👀",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isDone,
                                  onChanged: (_) => toggleTask(task),
                                  activeColor: Colors.deepPurple,
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: task.isDone ? Colors.grey : Colors.black,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => deleteTask(task.id),
                                ),
                              ),
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
