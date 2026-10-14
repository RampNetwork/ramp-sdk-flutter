import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

Future<List<String>> showAndroidFileSelector(FileSelectorParams params) async {
  try {
    if (params.isCaptureEnabled) {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);
      if (photo == null) {
        return const [];
      }
      return [Uri.file(photo.path).toString()];
    }

    final fileType = fileTypeForAcceptTypes(params.acceptTypes);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: params.mode == FileSelectorMode.openMultiple,
      type: fileType,
      allowedExtensions: fileType == FileType.custom ? extensionsForAcceptTypes(params.acceptTypes) : null,
    );
    if (result == null) {
      return const [];
    }
    return [
      for (final file in result.files)
        if (file.path != null) Uri.file(file.path!).toString(),
    ];
  } catch (error, stackTrace) {
    debugPrint('RampFlutter: file selection failed: $error\n$stackTrace');
    return const [];
  }
}

@visibleForTesting
FileType fileTypeForAcceptTypes(List<String> acceptTypes) {
  if (acceptTypes.isEmpty) {
    return FileType.any;
  }
  final normalized = acceptTypes.map((type) => type.toLowerCase().trim()).toList();
  final onlyImages = normalized.every((type) => type.startsWith('image/'));
  if (onlyImages) {
    return FileType.image;
  }
  final onlyVideos = normalized.every((type) => type.startsWith('video/'));
  if (onlyVideos) {
    return FileType.video;
  }
  final extensions = extensionsForAcceptTypes(acceptTypes);
  final allMappedToExtensions = normalized.every((type) => type.startsWith('.') || type == 'application/pdf');
  if (allMappedToExtensions && extensions != null && extensions.isNotEmpty) {
    return FileType.custom;
  }
  return FileType.any;
}

@visibleForTesting
List<String>? extensionsForAcceptTypes(List<String> acceptTypes) {
  final extensions = <String>{};
  for (final type in acceptTypes) {
    final value = type.trim().toLowerCase();
    if (value.startsWith('.')) {
      extensions.add(value.substring(1));
      continue;
    }
    if (value == 'application/pdf') {
      extensions.add('pdf');
    }
  }
  if (extensions.isEmpty) {
    return null;
  }
  return extensions.toList();
}
