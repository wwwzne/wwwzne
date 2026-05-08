import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'tools.dart';

class /*< download指令 >*/ Download extends Command {
  static const List<String> _templates = ['frontend', 'backend'];

  static const String _defaultTemplateUrl =
      'https://wwwzne.com/static/wwwzne-ui.zip';

  bool _askYesNo(String prompt, {bool defaultYes = false}) {
    final hint = defaultYes ? '[Y/n]' : '[y/N]';
    stdout.write('$prompt $hint: ');
    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input == null || input.isEmpty) {
      return defaultYes;
    }
    return input == 'y' || input == 'yes';
  }

  Future<void> _downloadAndExtractZip(String zipUrl) async {
    final uri = Uri.parse(zipUrl);
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('下载失败，HTTP ${response.statusCode}');
    }

    final tempZip = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}wwwzne_template.zip',
    );
    await tempZip.writeAsBytes(response.bodyBytes, flush: true);

    try {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      extractArchiveToDisk(archive, Tools.getCurDir());
    } finally {
      if (tempZip.existsSync()) {
        tempZip.deleteSync();
      }
    }
  }

  @override
  String get name => 'download';
  @override
  String get description => '构建项目基础模板';

  Download() {
    argParser.addOption(
      'template',
      abbr: 't',
      help: '模板名',
      allowed: ['frontend', 'backend'],
    );
  }
  @override
  Future<void> run() async {
    final name = (argResults?['template'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      print('⚠ 未指定模板，请使用 --template 选择模板');
      print('可下载模板选项: ${_templates.join(', ')}');
      print('示例: wwwzne download --template frontend');
      return;
    }

    if (name == 'frontend') {
      print('开始交互式安装: frontend');
      final useVite = _askYesNo('是否使用 Vite？');
      final installJest = _askYesNo('是否安装 Jest？');

      print('开始下载模板: $_defaultTemplateUrl');
      await _downloadAndExtractZip(_defaultTemplateUrl);
      print('模板已解压到当前文件夹');

      if (useVite) {
        print('已选择 Vite');
      }
      if (installJest) {
        print('已选择 Jest');
      }
      print('安装流程结束');
      return;
    }

    print('下载模板: $name');
  }
}
