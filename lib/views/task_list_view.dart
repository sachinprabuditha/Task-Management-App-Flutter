import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool _showCompletedTasks = false;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskViewModel>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Provider.of<TaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(_showCompletedTasks ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showCompletedTasks = !_showCompletedTasks;
              });
            },
            tooltip: _showCompletedTasks ? 'Hide Completed' : 'Show Completed',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          // Filter tasks based on completion status
          final filteredTasks = _showCompletedTasks 
            ? taskViewModel.tasks 
            : taskViewModel.tasks.where((task) => !(task.isCompleted ?? false)).toList();

          // Empty state
          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensure Column shrinks to fit content
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Tasks Available!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Conditional rendering between List and Grid view
          return _isGridView
            ? GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) => _buildTaskCard(
                  context, 
                  taskViewModel, 
                  filteredTasks[index],
                  isGridView: true,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) => _buildTaskCard(
                  context, 
                  taskViewModel, 
                  filteredTasks[index],
                  isGridView: false,
                ),
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskForm(context, taskViewModel);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskViewModel taskViewModel, Task task, {bool isGridView = false}) {
    final taskCard = Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted ?? false ? Colors.grey : Colors.black87,
                          decoration: task.isCompleted ?? false 
                            ? TextDecoration.lineThrough 
                            : TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Checkbox(
                      value: task.isCompleted ?? false,
                      onChanged: (bool? value) {
                        taskViewModel.toggleTaskCompletion(task);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    color: task.isCompleted ?? false 
                      ? Colors.grey[500] 
                      : Colors.grey[700],
                  ),
                  maxLines: isGridView ? 3 : null,
                  overflow: isGridView ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showTaskForm(context, taskViewModel, task: task);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  taskViewModel.deleteTask(task.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted successfully')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    return isGridView
      ? taskCard
      : Dismissible(
          key: Key(task.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            taskViewModel.deleteTask(task.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task deleted')),
            );
          },
          child: taskCard,
    );
  }

  void _showTaskForm(BuildContext context, TaskViewModel taskViewModel, {Task? task}) {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(text: task?.description);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,  // Ensures the form does not expand unnecessarily
            children: [
              Text(
                task == null ? 'Add New Task' : 'Edit Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newTask = Task(
                          id: task?.id,
                          title: titleController.text,
                          description: descriptionController.text,
                          isCompleted: task?.isCompleted,
                        );

                        task == null 
                          ? taskViewModel.addTask(newTask)
                          : taskViewModel.updateTask(newTask);

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
