import 'package:flutter/material.dart';
import 'modele_tache.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  TaskFormScreen({this.task, required this.onSave});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _status;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _status = widget.task?.status ?? 'todo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo App',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF333333),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? 'Ajouter' : 'Modifier',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: _getStatusColor(_status)),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _status,
                        items: [
                          _buildDropdownMenuItem('todo'),
                          _buildDropdownMenuItem('in progress'),
                          _buildDropdownMenuItem('done'),
                          _buildDropdownMenuItem('bug'),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _status = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                maxLines:
                    4, // Ajoute cette ligne pour permettre plusieurs lignes
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Task newTask = Task(
                        id: widget.task?.id,
                        title: _title,
                        description: _description,
                        completed: widget.task?.completed ?? false,
                        status: _status,
                      );
                      widget.onSave(newTask);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: Color(0xFF333333), // Couleur de fond noire
                    foregroundColor: Colors.white, // Couleur du texte blanche
                  ),
                  child: Text(widget.task == null ? 'Ajouter' : 'Modifier'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Action pour retourner à la page d'accueil
        },
        backgroundColor:
            Color(0xFF333333), // Même couleur de fond que le bouton "Ajouter"
        child: Icon(Icons.close, color: Colors.white),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String status) {
    return DropdownMenuItem<String>(
      value: status,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(status),
        ],
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
