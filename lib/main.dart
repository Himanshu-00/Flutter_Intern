import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      tasks = tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();
    });
  }

  void saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = tasks.map((task) => task.toJson()).toList();
    prefs.setStringList('tasks', tasksJson);
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      saveTasks();
    });
  }

  void completeTask(int index) {
    setState(() {
      tasks[index].isComplete = true;
      saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks yet',
                style: TextStyle(fontSize: 20.0),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskListItem(
                  task: tasks[index],
                  onComplete: () => completeTask(index),
                  onDelete: () => deleteTask(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen(addTask)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          fontSize: 18.0,
          decoration: task.isComplete ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(task.description),
      leading: Checkbox(
        value: task.isComplete,
        onChanged: (value) => onComplete(),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => onDelete(),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final Function(Task) addTaskCallback;

  AddTaskScreen(this.addTaskCallback);

  @override
  Widget build(BuildContext context) {
    String title = '';
    String description = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                title = value;
              },
            ),
            SizedBox(height: 10.0),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            SizedBox(height: 20.0),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      Task newTask = Task(title, description);
                      addTaskCallback(newTask);
                      Navigator.pop(context);
                    } else {
                      // error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Title cannot be empty'),
                        ),
                      );
                    }
                  },
                  child: Text('Add Task'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  String title;
  String description;
  bool isComplete;

  Task(this.title, this.description, {this.isComplete = false});

  Task.fromJson(String json)
      : title = json.split('::')[0],
        description = json.split('::')[1],
        isComplete = json.split('::')[2] == 'true';

  String toJson() {
    return '$title::$description::$isComplete';
  }
}
