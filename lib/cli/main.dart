import 'dart:io';
import 'package:colorize/colorize.dart';
import 'package:args/command_runner.dart';
import 'package:wwwzne/cli/compiler.dart';
import 'package:wwwzne/cli/test.dart';
import 'package:wwwzne/cli/help.dart';
import 'package:wwwzne/cli/download.dart';
import 'package:wwwzne/cli/script.dart';
// import 'qrcode.dart';

final /*< 作者logo >*/ wwwzne =
    """
888       888   888       888   888       888
888   o   888   888   o   888   888   o   888
888  d8b  888   888  d8b  888   888  d8b  888
888 d888b 888   888 d888b 888   888 d888b 888
888d88888b888   888d88888b888   888d88888b888
88888P Y88888   88888P Y88888   88888P Y88888
8888P   Y8888   8888P   Y8888   8888P   Y8888
888P     Y888   888P     Y888   888P     Y888

888888888888P   d888b    888b   d088888888889
       d888P    d8888b   888b   d0888b
      d888P     d88888b  888b   d0888b
     d888P      d888Y88b 888b   d08888888b
    d888P       d888 Y88b888b   d0888b999b
   d888P        d888  Y88888b   d0888b
  d888P         d888   Y8888b   d0888b
d888888888888   d888    Y888b   d088888888889
    """
        .trim();

final /*< 支持命令 >*/ knownCommands = [
  'script',
  'download',
  'test',
  'help',
  '--help',
  '-h',
  'rlpl',
  'rppl',
  'repl',
  // 'qrcode',
];

Future<void> main(List<String> arguments) async {
  final argv = List<String>.from(arguments);
  if (argv.isEmpty) {
    print(Colorize(wwwzne.trim()).lightGreen().bold().blink());
  } else if (!knownCommands.contains(argv.first)) {
    print(Colorize('未知指令').lightRed());
  } else {
    final runner = CommandRunner<void>('wwwzne', 'wwwzne 的 cli 工具')
      ..addCommand(Script())
      ..addCommand(Download())
      ..addCommand(Test())
      ..addCommand(Rlpl())
      ..addCommand(Rppl())
      ..addCommand(Repl())
    // ..addCommand(QrCode())
    ;
    if (argv.first == '-h' || argv.first == '--help' || argv.first == 'help') {
      stdout.writeln(help);
      for (final name in knownCommands.where(
        (name) => name != 'help' && name != '-h' && name != '--help',
      )) {
        final cmd = runner.commands[name];
        if (cmd != null) {
          stdout.writeln('  ${name.padRight(10)}${cmd.description}');
        }
      }
    } else {
      await runner.run(argv);
    }
  }
}
