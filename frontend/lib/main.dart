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
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
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
    setState(() => _isLoading = true);

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tasks'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _tasks = data.map((e) => Task.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Fetch error: $e');
    }
  }

  Future<void> addTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': text}),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        fetchTasks();
      }
    } catch (e) {
      debugPrint('Add error: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/api/tasks/$id'));

      if (response.statusCode == 200) {
        fetchTasks();
      }
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String currentDay = days[now.weekday - 1];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Todo App"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime date = monday.add(Duration(days: index));
                  bool isToday =
                      date.day == now.day && date.month == now.month;

                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              isToday ? Colors.deepPurple : Colors.white,
                          borderRadius:
                              BorderRadius.circular(isToday ? 15 : 30),
                        ),
                        child: Center(
                          child: Text(
                            "${date.day}",
                            style: TextStyle(
                              color: isToday
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(days[index]),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: "Add a task"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addTask,
                )
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Tasks"),
                Text(currentDay),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(child: Text("No tasks"))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, i) {
                            final t = _tasks[i];
                            return ListTile(
                              title: Text(t.title),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteTask(t.id),
                              ),
                            );
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }
}
