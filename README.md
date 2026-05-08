# wwwzne

> `wwwzne`是一个简易的可自定义的命令行工具。

||
|:---|
|[安装使用](#安装使用)|
|[配置文件](#配置文件)|
|[内置指令](#内置指令)|

## 安装使用

```shell
dart compile exe lib/cli/main.exe -o dist/cli/wwwzne.exe

```

## 配置文件

> wwwzne.config.json

配置文件的指令运行时会存在两个固定变量exeDir（工具存放目录）、curDir（当前目录）

## 内置指令

* test: `wwwzne test` 测试常用编程环境
* script: `wwwzne script` 执行配置的脚本
* index: `wwwzne index` 打开个人主页
* download: `wwwzne download` 下载开发模板
* help: `wwwzne help` 脚本工具帮助信息

> compiler

一个采用monkey语言的解释器逻辑实现的类似php的处理机制的语言解释器，支持wz语言（类mankey语言），可直接运行wz后缀的代码文本文件，也可将wz语法转义为dart语言。解释器底层为dart语言实现，wz语言的宿主语言为dart语言。

```mermaid
graph TD
    subgraph 解释器工作原理
        A[源代码] -->|词法分析| B[词法单元token]
        B -->|语法分析| C[抽象语法树AST]
        C -->|求值| D[结果]
    end
```

词法分析，由Lexer类的实例内部实现，直接打印实例可得到字符串形式的词法单元表示，其核心原理为：

1. 词法分析器维护一个输入字符串和两个指针（`position`、`readPosition`），通过`readChar`方法逐字符读取输入内容。
2. 每次调用`nextToken`，会跳过空白字符，然后根据当前字符（`ch`）判断其类型：如果是运算符、分隔符（如`=`、`+`、`-`、`;`、`(`、`)`等），直接生成对应的`Token`；如果是字母，则连续读取字母组成标识符或关键字（如`let`、`fn`、`if`等），并查表判断是否为关键字；如果是数字，则连续读取数字组成整数字面量。
3. 对于无法识别的字符，返回非法`Token`（`TokenType.illegal`）。
4. 每识别一个`Token`，都会调用`readChar`移动指针，准备下一个`Token`的分析。
5. 当读取到输入末尾时，返回`TokenType.eof`表示结束。
6. 整体流程是：跳过空白->判断字符类型->读取完整Token->返回Token->移动指针，直到输入结束。这样可以将源代码高效地分割为后续语法分析所需的`Token`。

语法分析，由Parser类的实例内部实现，直接打印实例可得到字符串形式的抽象语法树表示，其核心原理为：
