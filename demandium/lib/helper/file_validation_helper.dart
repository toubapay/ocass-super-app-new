import 'dart:io';
import 'package:demandium/common/enums/enums.dart';
import 'package:demandium/common/widgets/custom_snackbar.dart';
import 'package:demandium/feature/splash/controller/splash_controller.dart';
import 'package:demandium/util/app_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:image_picker/image_picker.dart';

class FileValidationHelper {
  /// Validates and picks an image with automatic config retrieval and error display
  /// Returns the picked XFile if valid, null otherwise
  static Future<XFile?> validateAndPickImage({
    required ImageSource source,
    double? maxHeight,
    double? maxWidth,
  }) async {
    try {
      // Step 1: Pick the image
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        imageQuality: AppConstants.defaultImageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
      );

      if (pickedImage == null) return null;

      // Step 2: Validate file extension
      final extensionError = validateFileExtension(file: pickedImage);

      if (extensionError != null) {
        customSnackBar(extensionError, type: ToasterMessageType.error);
        return null;
      }

      // Step 3: Get config and validate size
      final configModel = Get.find<ServiceSplashController>().configModel;
      final maxSize =
          configModel.content?.maxImageUploadSize ?? 20971520; // Default 20 MB

      final validationError = await validateFileSizeAsync(
        file: pickedImage,
        maxSizeInBytes: maxSize,
      );

      // Step 4: Show error if validation failed
      if (validationError != null) {
        customSnackBar(validationError, type: ToasterMessageType.error);
        return null;
      }

      // Step 5: Return valid file
      return pickedImage;
    } catch (error) {
      debugPrint('Image picking error: $error');
      return null;
    }
  }

  /// Validates and picks multiple images with automatic config retrieval and error display
  /// Returns the list of picked XFiles if all are valid, empty list otherwise
  static Future<List<XFile>> validateAndPickMultipleImages() async {
    try {
      // Step 1: Pick multiple images
      final picker = ImagePicker();
      final pickedImages = await picker.pickMultiImage(
        imageQuality: AppConstants.defaultImageQuality,
      );

      if (pickedImages.isEmpty) return [];

      // Step 2: Validate file extensions
      final extensionError = validateMultipleFileExtensions(
        files: pickedImages,
      );

      if (extensionError != null) {
        customSnackBar(extensionError, type: ToasterMessageType.error);
        return [];
      }

      // Step 3: Get config and validate sizes
      final configModel = Get.find<ServiceSplashController>().configModel;
      final maxSize =
          configModel.content?.maxImageUploadSize ?? 20971520; // Default 20 MB

      final validationError = await validateMultipleFilesSize(
        files: pickedImages,
        maxSizeInBytes: maxSize,
      );

      // Step 4: Show error if validation failed
      if (validationError != null) {
        customSnackBar(validationError, type: ToasterMessageType.error);
        return [];
      }

      // Step 5: Return valid files
      return pickedImages;
    } catch (error) {
      debugPrint('Multiple images picking error: $error');
      return [];
    }
  }

  /// Validates file extension using MIME type with fallback to file extension
  /// Returns null if valid, otherwise returns error message
  static String? validateFileExtension({required XFile file}) {
    try {
      // Try 1: Validate using MIME type (iOS/Web usually provides this)
      if (_isValidMimeType(file.mimeType)) {
        return null;
      }

      // Try 2: Validate using file extension from name or path (Android often needs this)
      final fileExtension = _extractFileExtension(file);
      if (_isValidExtension(fileExtension)) {
        return null;
      }

      // Return error if validation failed
      return _buildInvalidFileTypeError();
    } catch (e) {
      return _buildValidationFailedError(e);
    }
  }

  /// Checks if MIME type contains any allowed image extension
  static bool _isValidMimeType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) {
      return false;
    }

    final normalizedMimeType = mimeType.toLowerCase();
    return AppConstants.allowedImageExtensions.any(
      (extension) => normalizedMimeType.contains(extension),
    );
  }

  /// Extracts file extension from file name or path
  static String? _extractFileExtension(XFile file) {
    // Try getting extension from file name first
    if (file.name.isNotEmpty && file.name.contains('.')) {
      return file.name.toLowerCase().split('.').last;
    }

    // Fallback to file path
    if (file.path.contains('.')) {
      return file.path.toLowerCase().split('.').last;
    }

    return null;
  }

  /// Checks if file extension is in the allowed list
  static bool _isValidExtension(String? extension) {
    if (extension == null || extension.isEmpty) {
      return false;
    }

    return AppConstants.allowedImageExtensions.contains(extension);
  }

  /// Builds error message for invalid file type
  static String _buildInvalidFileTypeError() {
    final invalidFileType = 'invalid_file_type'.tr;
    final allowedFormats = 'allowed_formats'.tr;
    final extensions = AppConstants.allowedImageExtensions.join(', ');

    return '$invalidFileType. $allowedFormats: $extensions';
  }

  /// Builds error message for validation failure
  static String _buildValidationFailedError(Object error) {
    final failedMessage = 'failed_to_validate_file_type'.tr;
    return '$failedMessage: $error';
  }

  /// Validates multiple files extensions
  /// Returns null if all valid, otherwise returns error message for first invalid file
  static String? validateMultipleFileExtensions({required List<XFile> files}) {
    for (int i = 0; i < files.length; i++) {
      final error = validateFileExtension(file: files[i]);

      if (error != null) {
        return '${'file'.tr} ${i + 1}: $error';
      }
    }

    return null;
  }

  /// Validates file size asynchronously
  /// Returns null if valid, otherwise returns error message
  static Future<String?> validateFileSizeAsync({
    required XFile file,
    required int maxSizeInBytes,
  }) async {
    try {
      final fileSize = await file.length();

      if (fileSize > maxSizeInBytes) {
        return '${'file_size'.tr} (${formatFileSize(fileSize)}) ${'exceeds_maximum_allowed_size'.tr} (${formatFileSize(maxSizeInBytes)})';
      }

      return null;
    } catch (e) {
      return '${'failed_to_validate_file_size'.tr}: $e';
    }
  }

  /// Validates multiple files size
  /// Returns null if all valid, otherwise returns error message for first invalid file
  static Future<String?> validateMultipleFilesSize({
    required List<XFile> files,
    required int maxSizeInBytes,
  }) async {
    for (int i = 0; i < files.length; i++) {
      final error = await validateFileSizeAsync(
        file: files[i],
        maxSizeInBytes: maxSizeInBytes,
      );

      if (error != null) {
        return '${'file'.tr} ${i + 1}: $error';
      }
    }

    return null;
  }

  /// Validates total size of multiple files
  /// Returns null if valid, otherwise returns error message
  static Future<String?> validateTotalFilesSize({
    required List<XFile> files,
    required int maxTotalSizeInBytes,
  }) async {
    int totalSize = 0;

    for (final file in files) {
      totalSize += await file.length();
    }

    if (totalSize > maxTotalSizeInBytes) {
      return '${'file_size'.tr} (${formatFileSize(totalSize)}) ${'exceeds_maximum_allowed_size'.tr} (${formatFileSize(maxTotalSizeInBytes)})';
    }

    return null;
  }

  /// Converts bytes to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} ${'kb'.tr}';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} ${'mb'.tr}';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Gets file size from XFile
  static Future<int> getFileSize(XFile file) async {
    return await file.length();
  }

  /// Gets file size from File (for mobile)
  static int getFileSizeSync(File file) {
    return file.lengthSync();
  }

  /// Validates and picks document files with automatic config retrieval and error display
  /// Returns the list of picked PlatformFiles if all are valid, empty list otherwise
  static Future<List<PlatformFile>> validateAndPickDocuments() async {
    try {
      // Step 1: Pick document files
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withReadStream: true,
        allowedExtensions: AppConstants.allowedFileExtensions,
        type: FileType.custom,
      );

      if (result == null || result.files.isEmpty) return [];

      // Step 2: Validate file extensions
      final extensionError = validateMultipleDocumentExtensions(
        files: result.files,
      );

      if (extensionError != null) {
        customSnackBar(extensionError, type: ToasterMessageType.error);
        return [];
      }

      // Step 3: Get config and validate sizes
      final configModel = Get.find<ServiceSplashController>().configModel;
      final maxSize =
          configModel.content?.maxImageUploadSize ?? 20971520; // Default 20 MB

      final validationError = validateMultiplePlatformFilesSize(
        files: result.files,
        maxSizeInBytes: maxSize,
      );

      // Step 4: Show error if validation failed
      if (validationError != null) {
        customSnackBar(validationError, type: ToasterMessageType.error);
        return [];
      }

      // Step 5: Return valid files
      return result.files;
    } catch (error) {
      debugPrint('Document picking error: $error');
      return [];
    }
  }

  /// Validates document file extension
  /// Returns null if valid, otherwise returns error message
  static String? validateDocumentFileExtension({required PlatformFile file}) {
    try {
      // Extract file extension from name or path
      final fileExtension = _extractPlatformFileExtension(file);

      if (_isValidDocumentExtension(fileExtension)) {
        return null;
      }

      // Return error if validation failed
      return _buildInvalidDocumentTypeError();
    } catch (e) {
      return _buildValidationFailedError(e);
    }
  }

  /// Extracts file extension from PlatformFile name or path
  static String? _extractPlatformFileExtension(PlatformFile file) {
    // Try getting extension from file name first
    if (file.name.isNotEmpty && file.name.contains('.')) {
      return file.name.toLowerCase().split('.').last;
    }

    // Fallback to file path if available
    if (file.path != null && file.path!.contains('.')) {
      return file.path!.toLowerCase().split('.').last;
    }

    return null;
  }

  /// Checks if file extension is in the allowed document list
  static bool _isValidDocumentExtension(String? extension) {
    if (extension == null || extension.isEmpty) {
      return false;
    }

    return AppConstants.allowedFileExtensions.contains(extension);
  }

  /// Builds error message for invalid document type
  static String _buildInvalidDocumentTypeError() {
    final invalidFileType = 'invalid_file_type'.tr;
    final allowedFormats = 'allowed_formats'.tr;
    final extensions = AppConstants.allowedFileExtensions.join(', ');

    return '$invalidFileType. $allowedFormats: $extensions';
  }

  /// Validates multiple document files extensions
  /// Returns null if all valid, otherwise returns error message for first invalid file
  static String? validateMultipleDocumentExtensions({
    required List<PlatformFile> files,
  }) {
    for (int i = 0; i < files.length; i++) {
      final error = validateDocumentFileExtension(file: files[i]);

      if (error != null) {
        return '${'file'.tr} ${i + 1}: $error';
      }
    }

    return null;
  }

  /// Validates PlatformFile size
  /// Returns null if valid, otherwise returns error message
  static String? validatePlatformFileSizeSync({
    required PlatformFile file,
    required int maxSizeInBytes,
  }) {
    try {
      final fileSize = file.size;

      if (fileSize > maxSizeInBytes) {
        return '${'file_size'.tr} (${formatFileSize(fileSize)}) ${'exceeds_maximum_allowed_size'.tr} (${formatFileSize(maxSizeInBytes)})';
      }

      return null;
    } catch (e) {
      return '${'failed_to_validate_file_size'.tr}: $e';
    }
  }

  /// Validates multiple PlatformFiles size
  /// Returns null if all valid, otherwise returns error message for first invalid file
  static String? validateMultiplePlatformFilesSize({
    required List<PlatformFile> files,
    required int maxSizeInBytes,
  }) {
    for (int i = 0; i < files.length; i++) {
      final error = validatePlatformFileSizeSync(
        file: files[i],
        maxSizeInBytes: maxSizeInBytes,
      );

      if (error != null) {
        return '${'file'.tr} ${i + 1}: $error';
      }
    }

    return null;
  }
}
