import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('除封装层外不允许直接调用原生 SnackBar', () async {
    final rootPath = _normalizePath(Directory.current.absolute.path);
    final allowList = <String>{
      '$rootPath/lib/presentation/components/campus_snackbar.dart',
    };
    final pattern = RegExp(r'ScaffoldMessenger\.of\(|\bSnackBar\(');
    final violations = <String>[];

    for (final directoryName in ['lib', 'test']) {
      final directory = Directory('$rootPath/$directoryName');
      if (!directory.existsSync()) continue;

      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final filePath = _normalizePath(entity.path);
        if (allowList.contains(filePath)) continue;

        final content = await entity.readAsString();
        final lines = content.split('\n');
        for (var index = 0; index < lines.length; index++) {
          if (!pattern.hasMatch(lines[index])) continue;
          final relativePath = filePath.replaceFirst('$rootPath/', '');
          violations.add('$relativePath:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: '发现直接使用原生 SnackBar 的位置：\n${violations.join('\n')}',
    );
  });
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
