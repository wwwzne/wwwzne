import 'dart:io';
import 'dart:convert';

/*< 工具函数 >*/
class Tools {
  Tools._();

  static String getCurDir() => Directory.current.path;
  static String getExeDir() => File(Platform.resolvedExecutable).parent.path;

  ///TIP 执行shell指令
  ///param i: 参数执行别名
  ///param j: 传递的参数别名
  static (int, String) shellrun(String i, [List<String> j = const []]) {
    late final String executable;
    late final List<String> args;
    if (Platform.isWindows) {
      executable = 'cmd';
      args = ['/c', i];
    } else if (Platform.isLinux) {
      executable = 'bash';
      args = ['-lc', i];
    }
    final env = {'curDir': getCurDir(), 'exeDir': getExeDir()};
    for (var idx = 0; idx < j.length; idx++) {
      env['p${idx + 1}'] = j[idx];
    }
    final result = Process.runSync(executable, args, environment: env);
    final stdoutText = '${result.stdout}'.trim(),
        stderrText = '${result.stderr}'.trim();
    if (result.exitCode == 0) {
      return (result.exitCode, stdoutText);
    } else {
      return (result.exitCode, stderrText.isNotEmpty ? stderrText : stdoutText);
    }
  }

  ///TIP 读取json文件
  static Map<String, dynamic> readjson(File file) {
    if (!file.existsSync()) {
      return <String, dynamic>{};
    }
    final content = file.readAsStringSync();
    final data = jsonDecode(content);
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  ///TIP 判断是否为字母
  static bool isLetter(String? i) {
    if (i == null) return false;
    if (i.length != 1) return false;
    final code = i.codeUnitAt(0);
    return (code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)) ||
        (code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0)) ||
        code == '_'.codeUnitAt(0);
  }

  static bool isDigit(String? i) {
    if (i == null) return false;
    if (i.length != 1) return false;
    final code = i.codeUnitAt(0);
    return code >= '0'.codeUnitAt(0) && code <= '9'.codeUnitAt(0);
  }

  // ///TIP 编译器
  // static String compiler(String i) {
  //   return i.replaceAllMapped(RegExp(r'<\?wz(.*?)\?>', dotAll: true), (match) {
  //     String code = match.group(1) ?? '';
  //     code = code
  //         .replaceAll(RegExp(r'//.*'), '')
  //         .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  //     return '';
  //   });
  // }

  // ///TIP 词法分析
  // static List<TokenNode> lexer(String i) {
  //   return [];
  // }
}
