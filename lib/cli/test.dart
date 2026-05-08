import "package:args/command_runner.dart";
import "tools.dart";

class /*< 测试环境 >*/ Test extends Command {
  @override
  String get name => 'test';
  @override
  String get description => '个人常用的编程环境测试';

  @override
  void run() {
    for (final i in [
      ('PHP', 'php -v'),
      ('Dart', 'dart -v'),
      ('Node', 'node -v'),
      ('symfony', 'symfony -v'),
    ]) {
      final (a, b) = Tools.shellrun(i.$2);
      if (a != 0) {
        print('❌ ${i.$1} 未安装或不在 PATH 中');
      } else {
        final firstLine = b.isEmpty ? '已安装（未获取到版本输出）' : b.split('\n').first;
        print('✅ ${i.$1}: $firstLine');
      }
    }
  }
}
