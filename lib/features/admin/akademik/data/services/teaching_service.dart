// admin/akademik/data/services/teaching_service.dart

import 'package:dio/dio.dart';
import 'package:e_absensi/core/api/api_endpoints.dart';
import 'package:e_absensi/core/api/dio_client.dart';
import '../models/teaching_model.dart';
import 'dart:convert';

class TeachingService {
  final Dio _dio = DioClient().dio;

  Future<List<TeachingModel>> getAllTeachings() async {
    try {
      final response = await _dio.get(ApiEndpoints.getTeachings);
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TeachingModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Gagal mengambil data pengajaran');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat mengambil data.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> createTeaching(Map<String, dynamic> data) async {
    try {
      // Debug: Print data yang akan dikirim
      print("=== DATA YANG DIKIRIM KE SERVER ===");
      print("URL: ${ApiEndpoints.createTeaching}");
      print("Data: ${jsonEncode(data)}");
      print("==================================");

      // Pastikan data tidak null dan memiliki semua field yang diperlukan
      final validatedData = <String, dynamic>{};
      
      // Validasi dan assign setiap field
      if (data['id_guru'] != null) {
        validatedData['id_guru'] = data['id_guru'];
      } else {
        throw Exception('id_guru tidak boleh null');
      }
      
      if (data['id_mapel'] != null) {
        validatedData['id_mapel'] = data['id_mapel'];
      } else {
        throw Exception('id_mapel tidak boleh null');
      }
      
      if (data['id_kelas'] != null) {
        validatedData['id_kelas'] = data['id_kelas'];
      } else {
        throw Exception('id_kelas tidak boleh null');
      }
      
      if (data['hari'] != null && data['hari'].toString().isNotEmpty) {
        validatedData['hari'] = data['hari'];
      } else {
        throw Exception('hari tidak boleh kosong');
      }
      
      if (data['jam_mulai'] != null && data['jam_mulai'].toString().isNotEmpty) {
        validatedData['jam_mulai'] = data['jam_mulai'];
      } else {
        throw Exception('jam_mulai tidak boleh kosong');
      }
      
      if (data['jam_selesai'] != null && data['jam_selesai'].toString().isNotEmpty) {
        validatedData['jam_selesai'] = data['jam_selesai'];
      } else {
        throw Exception('jam_selesai tidak boleh kosong');
      }

      print("=== DATA SETELAH VALIDASI ===");
      print("Validated Data: ${jsonEncode(validatedData)}");
      print("============================");

      // Kirim request dengan data yang sudah divalidasi
      final response = await _dio.post(
        ApiEndpoints.createTeaching, 
        data: validatedData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=== RESPONSE DARI SERVER ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${jsonEncode(response.data)}");
      print("===========================");

      // Cek response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cek apakah response memiliki field 'status'
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;
          
          // Jika ada field 'status', cek nilainya
          if (responseData.containsKey('status')) {
            if (responseData['status'] == true || responseData['status'] == 'true') {
              // Berhasil
              return;
            } else {
              // Status false, ambil pesan error
              final errorMessage = responseData['message'] ?? 'Gagal membuat data pengajaran';
              throw Exception(errorMessage);
            }
          } else {
            // Tidak ada field 'status', anggap berhasil jika status code OK
            return;
          }
        } else {
          // Response bukan Map, anggap berhasil jika status code OK
          return;
        }
      } else {
        // Status code bukan 200/201
        final errorMessage = response.data['message'] ?? 'Gagal membuat data pengajaran (Status: ${response.statusCode})';
        throw Exception(errorMessage);
      }

    } on DioException catch (e) {
      print("=== DIO EXCEPTION ===");
      print("Type: ${e.type}");
      print("Message: ${e.message}");
      print("Response: ${e.response?.data}");
      print("Status Code: ${e.response?.statusCode}");
      print("====================");

      // Handle berbagai jenis DioException
      String errorMessage;
      
      if (e.response != null) {
        // Server merespons dengan error
        final responseData = e.response!.data;
        
        if (responseData is Map<String, dynamic>) {
          // Cek apakah ada pesan error spesifik
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else {
            errorMessage = 'Server error (${e.response!.statusCode})';
          }
          
          // Jika ada field validation errors
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            if (errors is Map<String, dynamic>) {
              final List<String> errorList = [];
              errors.forEach((key, value) {
                if (value is List) {
                  errorList.addAll(value.map((e) => '$key: $e'));
                } else {
                  errorList.add('$key: $value');
                }
              });
              errorMessage = errorList.join(', ');
            }
          }
        } else {
          errorMessage = 'Server error: ${responseData.toString()}';
        }
      } else {
        // Tidak ada response dari server
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            errorMessage = 'Connection timeout - periksa koneksi internet';
            break;
          case DioExceptionType.sendTimeout:
            errorMessage = 'Send timeout - periksa koneksi internet';
            break;
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Receive timeout - server tidak merespons';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'Connection error - tidak dapat terhubung ke server';
            break;
          case DioExceptionType.cancel:
            errorMessage = 'Request dibatalkan';
            break;
          default:
            errorMessage = 'Network error: ${e.message}';
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print("=== GENERIC EXCEPTION ===");
      print("Error: $e");
      print("========================");
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> updateTeaching(int id, Map<String, dynamic> data) async {
    try {
      print("=== UPDATE TEACHING ===");
      print("ID: $id");
      print("URL: ${ApiEndpoints.updateTeaching}/$id");
      print("Data: ${jsonEncode(data)}");
      print("======================");

      final response = await _dio.put(
        '${ApiEndpoints.updateTeaching}/$id', 
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=== UPDATE RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${jsonEncode(response.data)}");
      print("======================");

      if (response.statusCode != 200 || response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui data pengajaran');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat memperbarui data.');
    }
  }

  Future<void> deleteTeaching(int id) async {
    try {
      print("=== DELETE TEACHING ===");
      print("ID: $id");
      print("URL: ${ApiEndpoints.deleteTeaching}/$id");
      print("======================");

      final response = await _dio.delete(
        '${ApiEndpoints.deleteTeaching}/$id',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=== DELETE RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${jsonEncode(response.data)}");
      print("======================");

      if (response.statusCode != 200 || response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Gagal menghapus data pengajaran');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat menghapus data.');
    }
  }
}