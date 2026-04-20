import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
                  bool isToday = date.day == now.day && date.month == now.month;
                  
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
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
              ],
            ),
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