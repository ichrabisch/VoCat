import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/folder.dart';
import '../config/api_config.dart';

class FolderService {
  Future<bool> createFolder(Folder folder) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/Folder/createfolder'),
        headers: ApiConfig.headers,
        body: jsonEncode(folder.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating folder: $e');
      return false;
    }
  }

  Future<List<Folder>> getFolders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/Folder/selectallfolders?userId=$userId',
        ),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> folderList = jsonDecode(response.body);
        return folderList.map((json) => Folder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading folders: $e');
      return [];
    }
  }
}
