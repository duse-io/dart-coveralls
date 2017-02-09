library cmdpart;

import 'dart:async';
import 'dart:io' show FileSystemEntity;
import "dart:math" show max;

import "package:args/args.dart";
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

export "package:args/args.dart";

final Logger _log = new Logger("dart_coveralls");

abstract class CommandLinePart {
  final ArgParser parser;

  CommandLinePart(this.parser);

  String handlePackagesArg(ArgResults res) {
    String packagesPath = res["packages"];
    if (p.isRelative(packagesPath)) {
      packagesPath = p.absolute(packagesPath);
    }

    if (!FileSystemEntity.isFileSync(packagesPath)) {
      print("Packages file does not exist");
      return null;
    }

    _log.info(() => "Packages file is ${packagesPath}");

    return packagesPath;
  }

  static ArgParser addCommonOptions(ArgParser parser) {
    return parser
      ..addFlag("help", help: "Displays this help", negatable: false)
      ..addOption("packages",
          help:
              'Path to .packages file -- controls "package:..." import paths.',
          defaultsTo: ".packages");
  }

  Future parseAndExecute(List<String> args) => execute(parser.parse(args));

  Future execute(ArgResults res);
}

class CommandLineHubBuilder {
  final Map<PartInfo, CommandLinePart> _parts = {};

  void addPart(String name, CommandLinePart part, {String description: ""}) {
    _parts[new PartInfo(name, description: description)] = part;
  }

  CommandLinePart removePart(String name) => _parts.remove(name);

  CommandLineHub build() => new CommandLineHub._(_parts);
}

class CommandLineHub extends CommandLinePart {
  final Map<PartInfo, CommandLinePart> _parts;

  CommandLineHub._(Map<PartInfo, CommandLinePart> parts)
      : _parts = parts,
        super(_initializeParser(parts));

  Future execute(ArgResults results) async {
    if (results["help"]) {
      print(usage);
      return;
    }
    if (null == results.command) {
      print(usage);
      return;
    }
    var part = partByName(results.command.name);
    await part.execute(results.command);
  }

  CommandLinePart partByName(String name) {
    var partInfo = _parts.keys.firstWhere((info) => info.name == name);
    return _parts[partInfo];
  }

  int _getLongestNameLength() {
    var longest = 0;
    _parts.keys.forEach((part) => longest = max(longest, part.name.length));
    return longest;
  }

  String get usage {
    int len = _getLongestNameLength();
    return "Possible commands are: \n\n" +
        _parts.keys.map((info) => info.toString(len)).join("\n");
  }
}

class PartInfo {
  final String name;
  final String description;

  PartInfo(this.name, {this.description: ""});

  bool operator ==(other) {
    if (other is! PartInfo) return false;
    return other.name == this.name;
  }

  int get hashCode => name.hashCode;

  String toString([int nameLength]) {
    if (null == nameLength) nameLength = name.length;
    return "  ${name.padRight(nameLength)}\t$description";
  }
}

ArgParser _initializeParser(Map<PartInfo, CommandLinePart> parts) {
  var parser = new ArgParser(allowTrailingOptions: false);
  parts.forEach((info, part) => parser.addCommand(info.name, part.parser));
  parser.addFlag("help", negatable: false);
  return parser;
}
