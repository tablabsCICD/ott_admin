import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:admin_ott/app/core/constant/api_constant.dart';
import 'package:admin_ott/app/core/network/api_helper.dart';
import 'package:admin_ott/app/widgets/show_toast.dart';
import 'package:admin_ott/data/models/response/shorts_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;

class ShortsProvider extends ChangeNotifier {
  final ApiHelper _apiHelper = ApiHelper();

  List<ShortMaster> shorts = [];
  List<ShortMaster> _shortsByStatus = [];
  ShortDetailData? shortDetail;

  bool isLoading = false;
  bool isUploading = false;
  bool isSubmitting = false;
  bool isDetailLoading = false;
  bool isPartDeleting = false;
  bool isStatusListLoading = false;
  bool isUpdatingShortStatus = false;
  bool _isMovieUploading = false;
  double movieUploadProgress = 0.0;
  String? detailError;
  String? statusListError;
  int statusListTotalItems = 0;
  int statusListTotalPages = 0;
  int statusListCurrentPage = 0;
  String _currentStatusFilter = "PENDING";

  bool get isMovieUploading => _isMovieUploading;
  List<ShortMaster> get filteredShortsByStatus => _shortsByStatus;
  String get currentStatusFilter => _currentStatusFilter;

  final TextEditingController movieUrlController = TextEditingController();

  Future<void> fetchShorts() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await _apiHelper.getApi(ApiConstant.shortsMaster);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mapped = ShortMastersResponse.fromJson(data);
        shorts = mapped.data;
      } else {
        CustomToast.show(
          'Failed to fetch shorts (${response.statusCode})',
          isSuccess: false,
        );
      }
    } catch (e) {
      //log("Shorts fetch error -> $e");
      CustomToast.show('Failed to fetch shorts', isSuccess: false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addShortMaster(Map<String, dynamic> body) async {
    try {
      isSubmitting = true;
      notifyListeners();
      final response =
          await _apiHelper.postApiWithBody(ApiConstant.shortsMaster, body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await fetchShorts();
          CustomToast.show(data['message']?.toString() ?? 'Short created');
          return true;
        }
        CustomToast.show(
          data['message']?.toString() ?? 'Failed to create short',
          isSuccess: false,
        );
        return false;
      }
      CustomToast.show(
        'Create short failed (${response.statusCode})',
        isSuccess: false,
      );
      return false;
    } catch (e) {
      //log('Add short exception -> $e');
      CustomToast.show('Something went wrong while creating short',
          isSuccess: false);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShortMaster({required int shortId}) async {
    try {
      isLoading = true;
      notifyListeners();
      final response =
          await _apiHelper.deleteApi(ApiConstant.deleteShortMaster(shortId));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await fetchShorts();
          CustomToast.show(data['message']?.toString() ?? 'Short deleted');
          return true;
        }
      }
      CustomToast.show('Failed to delete short', isSuccess: false);
      return false;
    } catch (e) {
      //log('Delete short exception -> $e');
      CustomToast.show('Something went wrong while deleting short',
          isSuccess: false);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateShortMaster(
      Map<String, dynamic> body, String shortId) async {
    try {
      isSubmitting = true;
      notifyListeners();
      final response = await _apiHelper.putApiWithBody(
        ApiConstant.updateShortMaster(shortId),
        body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await fetchShorts();
          CustomToast.show(data['message']?.toString() ?? 'Short updated');
          return true;
        }
      }
      CustomToast.show('Failed to update short', isSuccess: false);
      return false;
    } catch (e) {
      //log('Update short exception -> $e');
      CustomToast.show('Something went wrong while updating short',
          isSuccess: false);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> fetchShortDetail({
    required int shortId,
    required int userId,
  }) async {
    try {
      isDetailLoading = true;
      detailError = null;
      notifyListeners();
      final response =
          await _apiHelper.getApi(ApiConstant.shortDetail(shortId));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final mapped = ShortDetailResponse.fromJson(decoded);
        shortDetail = mapped.data;
      } else {
        detailError = "Failed to load short details";
      }
    } catch (e) {
      detailError = e.toString();
      //log('Short detail exception -> $e');
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShortsByStatus({
    String status = "PENDING",
    int page = 0,
    int size = 10,
  }) async {
    try {
      isStatusListLoading = true;
      statusListError = null;
      _currentStatusFilter = status;
      notifyListeners();

      final response = await _apiHelper.getApi(
          ApiConstant.shortsByStatusPage(status, page: page, size: size));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mapped = ShortsByStatusPageResponse.fromJson(data);
        if (mapped.success == true && mapped.data != null) {
          _shortsByStatus = mapped.data!.shorts;
          statusListTotalItems = mapped.data!.totalItems;
          statusListTotalPages = mapped.data!.totalPages;
          statusListCurrentPage = mapped.data!.currentPage;
        } else {
          _shortsByStatus = [];
          statusListTotalItems = 0;
          statusListTotalPages = 0;
          statusListCurrentPage = page;
          statusListError = mapped.message ?? "Failed to fetch shorts";
        }
      } else {
        _shortsByStatus = [];
        statusListError = "Failed to fetch shorts (${response.statusCode})";
      }
    } catch (e) {
      _shortsByStatus = [];
      statusListError = "Something went wrong while fetching shorts";
    } finally {
      isStatusListLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateShortApprovalStatus({
    required int shortId,
    required String status,
    bool refreshPendingList = true,
  }) async {
    try {
      isUpdatingShortStatus = true;
      notifyListeners();

      final response = await _apiHelper.putApi(
        ApiConstant.approveShortStatus(shortId, status),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final updatedContent = data['data'] is Map<String, dynamic>
              ? (data['data'] as Map<String, dynamic>)['UpdatedContent']
              : null;
          final updatedMap = updatedContent is Map<String, dynamic>
              ? updatedContent
              : const <String, dynamic>{};
          if (shortDetail?.id == shortId) {
            shortDetail?.approvalStatus =
                updatedMap['approvalStatus']?.toString() ?? status;
            shortDetail?.approvedDateTime =
                updatedMap['approvedDateTime'] ?? shortDetail?.approvedDateTime;
          }
          _shortsByStatus.removeWhere((item) => item.id == shortId);
          if (refreshPendingList) {
            await fetchShortsByStatus(status: _currentStatusFilter);
          }
          CustomToast.show(data['message']?.toString() ?? "Status updated");
          return true;
        }
        CustomToast.show(
          data['message']?.toString() ?? "Failed to update short status",
          isSuccess: false,
        );
        return false;
      }
      CustomToast.show(
        "Failed to update short status (${response.statusCode})",
        isSuccess: false,
      );
      return false;
    } catch (e) {
      CustomToast.show("Something went wrong while updating status",
          isSuccess: false);
      return false;
    } finally {
      isUpdatingShortStatus = false;
      notifyListeners();
    }
  }

  Future<bool> createShortPart(Map<String, dynamic> body) async {
    try {
      isSubmitting = true;
      notifyListeners();
      final response =
          await _apiHelper.postApiWithBody(ApiConstant.shortParts, body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final success = decoded['success'] == true;
        if (success) {
          CustomToast.show(decoded['message']?.toString() ?? 'Part created');
          return true;
        }
      }
      CustomToast.show('Failed to create short part', isSuccess: false);
      return false;
    } catch (e) {
      //log('Create part exception -> $e');
      CustomToast.show('Create short part failed', isSuccess: false);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShortPart({required String partId}) async {
    try {
      isPartDeleting = true;
      notifyListeners();
      final response =
          await _apiHelper.deleteApi(ApiConstant.deleteShortPart(partId));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) return true;
      }
      return false;
    } catch (e) {
      //log('Delete part exception -> $e');
      return false;
    } finally {
      isPartDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> updateShortPart(Map<String, dynamic> body, String partId) async {
    try {
      isSubmitting = true;
      notifyListeners();
      final response = await _apiHelper.putApiWithBody(
        ApiConstant.updateShortPart(partId),
        body,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true;
      }
      return false;
    } catch (e) {
      //log('Update part exception -> $e');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> uploadVideoWeb() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final xhr = html.HttpRequest();
      final formData = html.FormData();
      formData.appendBlob('video', file, file.name);

      xhr.upload.onProgress.listen((e) {
        if (e.lengthComputable == true &&
            e.loaded != null &&
            e.total != null &&
            e.total! > 0) {
          movieUploadProgress = e.loaded! / e.total!;
          notifyListeners();
        }
      });

      xhr.onLoad.listen((_) {
        try {
          if (xhr.status == 200 && xhr.responseText != null) {
            final response = json.decode(xhr.responseText!);
            final data = response['data'];
            final url = data is Map<String, dynamic>
                ? data['videoUrl'] ?? data['encryptedUrl'] ?? data['fileUrl']
                : null;
            if (url != null) {
              movieUrlController.text = url.toString();
              movieUploadProgress = 1.0;
              CustomToast.show('Video uploaded successfully');
            } else {
              movieUploadProgress = 0.0;
              CustomToast.show('Upload succeeded but video URL missing',
                  isSuccess: false);
            }
          } else {
            movieUploadProgress = 0.0;
            CustomToast.show('Video upload failed', isSuccess: false);
          }
        } finally {
          _isMovieUploading = false;
          isUploading = false;
          notifyListeners();
        }
      });

      xhr.onError.listen((_) {
        movieUploadProgress = 0.0;
        _isMovieUploading = false;
        isUploading = false;
        notifyListeners();
        CustomToast.show('Video upload failed', isSuccess: false);
      });

      xhr.open('POST', ApiConstant.uploadVideo);
      xhr.send(formData);

      _isMovieUploading = true;
      isUploading = true;
      notifyListeners();
    });
  }

  Future<void> uploadVideo() async {
    final uploadUri = Uri.parse(ApiConstant.uploadVideo);

    movieUploadProgress = 0.0;
    _isMovieUploading = true;
    isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        await uploadVideoWeb();
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile == null) {
        movieUploadProgress = 0.0;
        _isMovieUploading = false;
        isUploading = false;
        notifyListeners();
        return;
      }

      final file = io.File(pickedFile.path);
      final totalBytes = await file.length();
      int bytesSent = 0;

      final progressStream = file.openRead().transform(
        StreamTransformer.fromHandlers(
          handleData: (List<int> data, EventSink<List<int>> sink) {
            bytesSent += data.length;
            movieUploadProgress = bytesSent / totalBytes;
            notifyListeners();
            sink.add(data);
          },
        ),
      );

      final request = http.MultipartRequest('POST', uploadUri);
      request.files.add(
        http.MultipartFile(
          'video',
          progressStream,
          totalBytes,
          filename: pickedFile.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final responseJson = json.decode(responseBody);
        final data = responseJson['data'];
        final url = data is Map<String, dynamic>
            ? data['videoUrl'] ?? data['encryptedUrl'] ?? data['fileUrl']
            : null;
        if (url != null) {
          movieUrlController.text = url.toString();
          movieUploadProgress = 1.0;
          CustomToast.show('Video uploaded successfully');
        } else {
          movieUploadProgress = 0.0;
          CustomToast.show('Video upload response invalid', isSuccess: false);
        }
      } else {
        movieUploadProgress = 0.0;
        CustomToast.show('Video upload failed (${response.statusCode})',
            isSuccess: false);
      }
    } catch (e) {
      movieUploadProgress = 0.0;
      //log('Video upload error -> $e');
      CustomToast.show('Error uploading video', isSuccess: false);
    } finally {
      if (!kIsWeb) {
        _isMovieUploading = false;
        isUploading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> uploadThumbnail(
      io.File? imageFile, html.File? webFile) async {
    try {
      final uri = Uri.parse(ApiConstant.uploadImg);
      final request = http.MultipartRequest('POST', uri);

      if (kIsWeb && webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(webFile);
        await reader.onLoad.first;
        final result = reader.result;
        if (result is! List<int>) return null;
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            result,
            filename: webFile.name,
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      } else {
        return null;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(responseBody);
      if (decoded is String) return decoded;
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return data['thumbnailUrl']?.toString() ??
              data['fileUrl']?.toString() ??
              data['url']?.toString();
        }
        if (data is String) return data;
        return decoded['thumbnailUrl']?.toString() ??
            decoded['fileUrl']?.toString() ??
            decoded['url']?.toString();
      }
      return null;
    } catch (e) {
      //log('Upload thumbnail error -> $e');
      return null;
    }
  }

  void removeShortLocally(int shortId) {
    shorts.removeWhere((e) => e.id == shortId);
    notifyListeners();
  }

  void restoreShort(ShortMaster short, int index) {
    shorts.insert(index, short);
    notifyListeners();
  }
}
