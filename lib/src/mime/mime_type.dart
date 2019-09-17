library parse_mime_type;

part 'mime_db.dart';

Map _extensions;

/// Get the default extension for a given content type.
String getExtension(String contentType) {
  if (_contentTypes.containsKey(contentType) &&
      _contentTypes[contentType].containsKey('extensions')) {
    return _contentTypes[contentType]['extensions'].first;
  }
  return null;
}

/// Get the content type for a given extension or file path.
String getContentType(String extension) {
  _processDb();
  if (extension.lastIndexOf('.') >= 0) {
    // assume a file name or path
    extension = extension.substring(extension.lastIndexOf('.') + 1);
  }
  String contentType = _extensions[extension.toLowerCase()];

  if (contentType == null) {
    contentType = 'application/octet-stream';
  }

  return contentType;
}

/// Lazily process the content types in a map indexed by extension.
void _processDb() {
  if (_extensions == null) {
    _extensions = {};
    _contentTypes.forEach((type, typeInfo) {
      if (typeInfo.containsKey('extensions')) {
        for (String ext in typeInfo['extensions']) {
          _extensions[ext] = type;
        }
      }
    });
  }
}
