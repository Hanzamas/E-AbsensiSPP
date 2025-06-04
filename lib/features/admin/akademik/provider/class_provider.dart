import 'package:flutter/material.dart';
import '../data/repositories/class_repository.dart';
import '../data/models/class_model.dart';

class ClassProvider extends ChangeNotifier {
  static final ClassProvider _instance = ClassProvider._internal();
  final ClassRepository _repository = ClassRepository();
  
  bool _isLoading = false;
  String? _error;
  List<ClassModel> _classes = [];

  // Private constructor
  ClassProvider._internal();

  // Singleton factory
  factory ClassProvider() => _instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClassModel> get classes => _classes;

  // Load all classes
  Future<void> loadClasses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _classes = await _repository.getAllClasses();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading classes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new class
  Future<bool> createClass(ClassModel classData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newClass = await _repository.createClass(classData);
      _classes.add(newClass);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing class
  Future<bool> updateClass(int id, ClassModel classData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedClass = await _repository.updateClass(id, classData);
      final index = _classes.indexWhere((c) => c.id == id);
      if (index != -1) {
        _classes[index] = updatedClass;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete class
  Future<bool> deleteClass(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final success = await _repository.deleteClass(id);
      if (success) {
        _classes.removeWhere((c) => c.id == id);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting class: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 