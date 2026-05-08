import "package:args/command_runner.dart";
import 'dart:io';
import 'tools.dart';

///TIP script执行命令
class Script extends Command {
  final ({
    Map<String, dynamic> globalConfig,
    Map<String, dynamic> localConfig,
    Map<String, dynamic> allowed,
  })
  _configs;

  @override
  String get name => 'script';
  @override
  String get description => '执行设置的脚本';

  Script() : _configs = _allowedInit() {
    argParser.addOption('name', abbr: 'n', help: '脚本名字');
  }

  static ({
    Map<String, dynamic> globalConfig,
    Map<String, dynamic> localConfig,
    Map<String, dynamic> allowed,
  })
  _allowedInit() {
    final exeDirFile = File(
      '${Tools.getExeDir()}${Platform.pathSeparator}wwwzne.config.json',
    );
    final curPathFile = File(
      '${Tools.getCurDir()}${Platform.pathSeparator}wwwzne.config.json',
    );
    final globalConfig = Tools.readjson(exeDirFile);
    final localConfig = Tools.readjson(curPathFile);
    return (
      globalConfig: globalConfig,
      localConfig: localConfig,
      allowed: <String, dynamic>{...globalConfig, ...localConfig},
    );
  }

  @override
  void run() {
    final scriptName = argResults?['name'] as String? ?? '';
    if (scriptName == '') {
      print("全局脚本");
      for (final i in _configs.globalConfig.keys) {
        print("  $i: ${_configs.globalConfig[i][0]}");
      }
      print("局部脚本");
      for (final i in _configs.localConfig.keys) {
        print("  $i: ${_configs.localConfig[i][0]}");
      }
    } else {
      final command = _configs.allowed[scriptName];
      if (command == null || command.isEmpty) {
        print('未找到脚本: $scriptName');
        return;
      }
      String j = '';
      for (final i in command.sublist(1)) {
        j += ' ${i.toString()} &&';
      }
      if ((argResults?.rest ?? []).isEmpty) {
        print("未指定文件名");
      } else {
        final result = Tools.shellrun(
          j.substring(0, j.length - 2),
          argResults?.rest ?? [],
        );
        print(result.$2);
      }
    }
  }
}
