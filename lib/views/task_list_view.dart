import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../models/task.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  bool _showCompletedTasks = false;
  bool _isGridView = false;
  String _searchQuery = ''; // For filtering tasks

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          // Filter tasks based on completion status and search query
          final filteredTasks = taskViewModel.tasks
              .where((task) => (_showCompletedTasks || !(task.isCompleted ?? false)) &&
                  (task.title.toLowerCase().contains(_searchQuery) ||
                      task.description.toLowerCase().contains(_searchQuery)))
              .toList();

          // Empty state
          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Tasks Found!',
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
    elevation: 6, // Slightly lower elevation for a subtler shadow effect
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Reduced margins for a smaller card
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Less rounded corners for a sleeker look
    ),
    color: task.isCompleted ?? false ? Colors.grey[200] : const Color.fromARGB(255, 233, 242, 252), // Background color for completed tasks
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding for a more compact card
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
                        fontSize: 16, // Slightly smaller font size
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
              const SizedBox(height: 6),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14, // Smaller description text
                  color: task.isCompleted ?? false
                      ? Colors.grey[600]
                      : Colors.black54,
                ),
                maxLines: isGridView ? 2 : null, // Adjusted for compactness
                overflow: isGridView ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
        // ignore: deprecated_member_use
        ButtonBar(
          alignment: MainAxisAlignment.end,
          buttonMinWidth: 48, // Compact button width
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () {
                _showTaskForm(context, taskViewModel, task: task);
              },
              splashColor: Colors.blue.withOpacity(0.3), // Add splash effect
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                taskViewModel.deleteTask(task.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted successfully')),
                );
              },
              splashColor: Colors.red.withOpacity(0.3), // Add splash effect
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              task == null ? 'Add New Task' : 'Edit Task',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title TextField
            _buildTextField(
              controller: titleController,
              label: 'Title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            // Description TextField
            _buildTextField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Save/Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  text: 'Cancel',
                  color: Colors.grey[600]!,
                  onPressed: () => Navigator.pop(context),
                ),
                _buildActionButton(
                  text: 'Save',
                  color: Colors.blueAccent,
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

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  String? Function(String?)? validator,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blueAccent),
      hintText: 'Enter $label',
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1, color: Color.fromARGB(255, 230, 230, 230)),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: validator,
  );
}

Widget _buildActionButton({
  required String text,
  required Color color,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      minimumSize: const Size(120, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    onPressed: onPressed,
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}

}
