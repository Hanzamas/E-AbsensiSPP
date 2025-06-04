import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/class_model.dart';

class ClassService {
  final String baseUrl = 'YOUR_API_BASE_URL'; // TODO: Replace with actual base URL

  Future<List<ClassModel>> getAllClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/classes'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final List<dynamic> classesData = responseData['data'];
          return classesData.map((data) => ClassModel.fromJson(data)).toList();
        }
        throw Exception(responseData['message']);
      }
      throw Exception('Failed to load classes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ClassModel> createClass(ClassModel classData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/classes/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(classData.toCreateJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          // Since the API only returns insertId, we'll create a new ClassModel
          // with the returned ID and the input data
          return ClassModel(
            id: responseData['data']['insertId'],
            nama: classData.nama,
            kapasitas: classData.kapasitas,
            idTahunAjaran: classData.idTahunAjaran,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        throw Exception(responseData['message']);
      }
      throw Exception('Failed to create class');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<ClassModel> updateClass(int id, ClassModel classData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/classes/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(classData.toUpdateJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return ClassModel.fromJson(responseData['data']);
        }
        throw Exception(responseData['message']);
      }
      throw Exception('Failed to update class');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/classes/delete/$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == true;
      }
      throw Exception('Failed to delete class');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 