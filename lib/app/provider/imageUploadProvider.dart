import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/network/api_helper.dart';
import '../core/loading/app_loading_controller.dart';
import 'package:universal_html/html.dart' as html;

import 'package:image_picker/image_picker.dart'; // For web-specific file handling

class UploadImageProvider with ChangeNotifier {
  io.File? _imageFile; // For mobile platforms
  html.File? _webFile; // For web platform
  String? _uploadedImageUrl;
  bool _isUploading = false;

  // Getters
  io.File? get imageFile => _imageFile;
  html.File? get webFile => _webFile;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isUploading => _isUploading;

  // Pick Image
  Future<void> pickImage() async {
    if (kIsWeb) {
      // Web file picker
      final html.FileUploadInputElement uploadInput =
      html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          notifyListeners();
        }
      });
    } else {
      // Mobile/desktop file picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = io.File(pickedFile.path);
        notifyListeners();
      }
    }
  }

  // Upload Image
  Future<void> uploadImage() async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      return; // No file selected
    }

    final url = Uri.parse(
        'http://ec2-13-233-173-37.ap-south-1.compute.amazonaws.com:8080/ottNew/api/saveImage/new');
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb && _webFile != null) {
        // Web upload logic
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;

        final byteData = reader.result as List<int>;
        final multipartFile = http.MultipartFile.fromBytes(
          'profilePicture',
          byteData,
          filename: _webFile!.name,
        );

        request.files.add(multipartFile);
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic
        final request = http.MultipartRequest('POST', url);
        request.headers.addAll(await ApiHelper().multipartHeaders());
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
        //  contentType: MediaType('image', 'jpeg'),
        ));
        final response =
            await AppLoadingController.trackFuture(() => request.send());

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
