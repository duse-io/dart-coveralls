library dart_coveralls.test.mocks;

import 'dart:io' show ProcessResult;

import 'package:dart_coveralls/dart_coveralls.dart';
import 'package:file/file.dart';
import 'package:mockito/mockito.dart';

class FileSystemMock extends Mock implements FileSystem {}

class FileMock extends Mock implements File {}

class DirectoryMock extends Mock implements Directory {}

class ProcessResultMock extends Mock implements ProcessResult {}

class ProcessSystemMock extends Mock implements ProcessSystem {}
