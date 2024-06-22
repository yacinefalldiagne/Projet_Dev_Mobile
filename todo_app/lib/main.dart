import 'package:flutter/material.dart';
import 'modele_tache.dart';
import 'bdd.dart';
import 'ecran_formulaire_tache.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333)),
          headline2: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F4F4F)),
          headline3: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F4F4F)),
          headline4: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4F4F4F)),
        ),
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final BDTache _databaseHelper = BDTache();
  List<Task> _tasks = [];
  List<String> _selectedStatuses = ['todo', 'in progress', 'done', 'bug'];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    List<Map<String, dynamic>> taskMaps =
        await _databaseHelper.getTasksByStatuses(_selectedStatuses);
    setState(() {
      _tasks = taskMaps.map((map) => Task.fromMap(map)).toList();
    });
  }

  void _addTask(Task task) async {
    await _databaseHelper.insertTask(task.toMap());
    _fetchTasks();
  }

  void _updateTask(Task task) async {
    await _databaseHelper.updateTask(task.toMap());
    _fetchTasks();
  }

  void _deleteTask(int id) async {
    await _databaseHelper.deleteTask(id);
    _fetchTasks();
  }

  void _openTaskForm({Task? task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          task: task,
          onSave: (Task newTask) {
            if (task == null) {
              _addTask(newTask);
            } else {
              _updateTask(newTask);
            }
          },
        ),
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterMenu(
          selectedStatuses: _selectedStatuses,
          onApply: (List<String> selectedStatuses) {
            setState(() {
              _selectedStatuses = selectedStatuses;
            });
            _fetchTasks();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo App',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF333333),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          Task task = _tasks[index];
          return TaskItem(
            task: task,
            onTap: () {
              _openTaskForm(task: task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openTaskForm();
        },
        backgroundColor: Color(0xFF333333),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class FilterMenu extends StatefulWidget {
  final List<String> selectedStatuses;
  final Function(List<String>) onApply;

  FilterMenu({required this.selectedStatuses, required this.onApply});

  @override
  _FilterMenuState createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu> {
  late List<String> _tempSelectedStatuses;

  @override
  void initState() {
    super.initState();
    _tempSelectedStatuses = List.from(widget.selectedStatuses);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter by status',
              style: Theme.of(context).textTheme.headline2),
          CheckboxListTile(
            title: Text('Todo'),
            value: _tempSelectedStatuses.contains('todo'),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedStatuses.add('todo');
                } else {
                  _tempSelectedStatuses.remove('todo');
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('In progress'),
            value: _tempSelectedStatuses.contains('in progress'),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedStatuses.add('in progress');
                } else {
                  _tempSelectedStatuses.remove('in progress');
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('Done'),
            value: _tempSelectedStatuses.contains('done'),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedStatuses.add('done');
                } else {
                  _tempSelectedStatuses.remove('done');
                }
              });
            },
          ),
          CheckboxListTile(
            title: Text('Bug'),
            value: _tempSelectedStatuses.contains('bug'),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _tempSelectedStatuses.add('bug');
                } else {
                  _tempSelectedStatuses.remove('bug');
                }
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.onApply(_tempSelectedStatuses);
                },
                child: Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  TaskItem({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor(task.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: statusColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(task.title,
                  style: Theme.of(context).textTheme.headline3),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Color(0xFF333333);
      case 'in progress':
        return Color(0xFF56CCF2);
      case 'done':
        return Color(0xFF27AE60);
      case 'bug':
        return Color(0xFFEB5757);
      default:
        return Colors.black;
    }
  }
}
