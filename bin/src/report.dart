library dart_coveralls.report;

import 'dart:io';
import 'dart:async' show runZoned;

import 'package:dart_coveralls/dart_coveralls.dart';

import "command_line.dart";

class ReportPart extends CommandLinePart {
  final ArgParser parser;

  ReportPart() : parser = _initializeParser();

  static ArgParser _initializeParser() {
    return new ArgParser(allowTrailingOptions: true)
      ..addFlag("help", help: "Displays this help", negatable: false)
      ..addOption("token",
          help: "Token for coveralls", defaultsTo: Platform.environment["test"])
      ..addFlag("calc",
          help: "Calculate coverage before reporting", defaultsTo: true)
      ..addOption("workers",
          help: "Number of workers for parsing", defaultsTo: "1")
      ..addOption("package-root", help: "Root package", defaultsTo: ".")
      ..addFlag("debug", help: "Prints debug information", negatable: false)
      ..addOption("retry", help: "Number of retries", defaultsTo: "10")
      ..addFlag("dry-run",
          help: "If this flag is enabled, data won't" + " be sent to coveralls",
          negatable: false)
      ..addFlag("throw-on-connectivity-error",
          help: "Should this throw an " +
              "exception, if the upload to coveralls fails?",
          negatable: false,
          abbr: "C")
      ..addFlag("throw-on-error",
          help: "Should this throw if " +
              "an error in the dart_coveralls implementation happens?",
          negatable: false,
          abbr: "E")
      ..addFlag("exclude-test-files",
          abbr: "T",
          help: "Should test files " + "be included in the coveralls report?",
          negatable: false);
  }

  void execute(ArgResults res) {
    var calc = res["calc"];

    if (res["help"]) return print(parser.usage);
    if (res.rest.length != 1 && calc) return print("Please specify a test file to run");
    if (res.rest.length != 1 && !calc) return print("Please specify an lcov input file");
    if (res["debug"]) {
      log.onRecord.listen((rec) => print(rec));
    }

    var pRoot = new Directory(res["package-root"]);
    var file = new File(res.rest.single);
    var dryRun = res["dry-run"];
    var token = res["token"];
    var workers = int.parse(res["workers"]);
    var retry = int.parse(res["retry"]);
    var throwOnError = res["throw-on-error"];
    var throwOnConnectivityError = res["throw-on-connectivity-error"];
    var excludeTestFiles = res["exclude-test-files"];

    if (calc) {
      if (!pRoot.existsSync()) return print("Root directory does not exist");
      log.info(() => "Package root is ${pRoot.absolute.path}");
      if (!file.existsSync()) return print("Dart file does not exist");
      log.info(() => "Evaluated dart file is ${file.absolute.path}");
    } else {
      if (!file.existsSync()) return print("lcov file does not exist");
      log.info(() => "Evaluated lcov file is ${file.absolute.path}");
    }
    if (token == null && dryRun) {
      token = "test";
    }

    var errorFunction = (e) {
      if (throwOnError) throw e;
    };

    try {
      var commandLineClient = new CommandLineClient(pRoot, token: token);
      // We don't print out the token here as it could end up in public build logs.
      log.info("Token is ${(token == null || token.isEmpty) ? 'empty' : 'not empty'}");
      if (commandLineClient.token == null) {
        return print("Please specify a repo token");
      }
      runZoned(() {
        commandLineClient.reportToCoveralls(file,
            calc: calc,
            workers: workers,
            dryRun: dryRun,
            retry: retry,
            throwOnConnectivityError: throwOnConnectivityError,
            excludeTestFiles: excludeTestFiles);
      }, onError: errorFunction);
    } catch (e) {
      errorFunction(e);
    }
  }
}
