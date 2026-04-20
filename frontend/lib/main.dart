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
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Fixed typo: 'false' instead of 'flase'
  bool _isDarkMode = false; 

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) { // Fixed typo: 'BuildContext'
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Define Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      // Define Dark Theme logic
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Pass state and function to TodoPage
      home: TodoPage(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
    );
  }
}

class TodoPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const TodoPage({
    super.key, 
    required this.isDarkMode, 
    required this.onThemeChanged
  });

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
  final List<String> _tasks = [];

  @override
  Widget build(BuildContext context) {
    // --- Calendar logic --
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String currentDay = days[now.weekday - 1];
    //-------------

    return Scaffold(
      // Uses a dynamic background color
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black 
          : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Todo App"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme Toggle Button
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Calendar
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime date = monday.add(Duration(days: index));
                  bool isToday =
                      date.day == now.day && date.month == now.month;

                  bool isToday = date.day == now.day && date.month == now.month;
                  
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
                          // Dynamic color: Purple if today, otherwise the theme's card color
                          color: isToday ? Colors.deepPurple : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(isToday ? 15 : 30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                            ),
                          ],
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
                              color: isToday ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        days[index],
                        style: TextStyle(
                          color: isToday ? Colors.deepPurple : Colors.grey,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
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
            // --- Input Container ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple, size: 32),
                    onPressed: () {
                      setState(() {
                        if (_controller.text.isNotEmpty) {
                          _tasks.add(_controller.text);
                          _controller.clear();
                        }
                      });
                    },
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
                    color: Colors.deepPurple[300],
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
            const SizedBox(height: 10),

            // --- Task List ---
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text("No tasks yet!"))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(_tasks[index]),
                            leading: const Icon(Icons.circle_outlined, color: Colors.deepPurple),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _tasks.removeAt(index);
                                });
                              },
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
