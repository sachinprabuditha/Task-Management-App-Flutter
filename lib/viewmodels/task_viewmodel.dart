import 'package:flutter/material.dart';
import 'package:task_manager/database/database_helper.dart';
import '../models/task.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseService _databaseService = DatabaseService();

  List<Task> get tasks => _tasks;

  // Load tasks from database
  Future<void> loadTasks() async {
    _tasks = await _databaseService.getTasks();
    notifyListeners();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final newTask = await _databaseService.insertTask(task);
    _tasks.add(newTask);
    notifyListeners();
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _databaseService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  // Delete a task
  Future<void> deleteTask(int taskId) async {
    await _databaseService.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: !(task.isCompleted ?? false),
    );
    await updateTask(updatedTask);
  }
}