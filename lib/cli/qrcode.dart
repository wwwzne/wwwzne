import "package:args/command_runner.dart";
import 'dart:convert';
import 'dart:math';

enum encodingMode { numreic, alphanumeric, byte, kanji }

class QrCode extends Command {
  @override
  String get name => 'qrcode';
  @override
  String get description => "二维码生成";
  @override
  void run() {
    if (argResults != null && argResults!.rest.isNotEmpty) {}
  }

  encodingMode detectBestEncodingMode(String text) {
    if (RegExp(r'^[0-9]*$').hasMatch(text)) {
      return encodingMode.numreic;
    } else if (RegExp(r'^[0-9 A-Z $%*+\-./:]*$').hasMatch(text)) {
      return encodingMode.alphanumeric;
    } else if (RegExp(r'^[\x00-\x7F]*$').hasMatch(text)) {
      return encodingMode.byte;
    } else {
      return encodingMode.byte;
    }
  }

  int getCharCountIndicatorLength(int version, encodingMode mode) {
    if (version >= 1 && version <= 9) {
      return {
        encodingMode.numreic: 10,
        encodingMode.alphanumeric: 9,
        encodingMode.byte: 8,
        encodingMode.kanji: 8,
      }[mode]!;
    } else if (version >= 10 && version <= 26) {
      return {
        encodingMode.numreic: 12,
        encodingMode.alphanumeric: 11,
        encodingMode.byte: 16,
        encodingMode.kanji: 10,
      }[mode]!;
    } else {
      return {
        encodingMode.numreic: 14,
        encodingMode.alphanumeric: 13,
        encodingMode.byte: 16,
        encodingMode.kanji: 12,
      }[mode]!;
    }
  }

  String encodeNumeric(String data) {
    String bits = '';
    for (int i = 0; i < data.length; i += 3) {
      String group = data.substring(i, 3);
      int num = int.parse(group);
      int bitLength;
      if (group.length == 1) {
        bitLength = 4;
      } else if (group.length == 2) {
        bitLength = 7;
      } else {
        bitLength = 10;
      }
      String binary = num.toRadixString(2);
      while (binary.length < bitLength) {
        binary = '0$binary';
      }
      bits += binary;
    }
    return bits;
  }

  String encodeAlphanumeric(String data) {
    String charMap = r'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:';
    String bits = '';
    for (int i = 0; i < data.length; i += 2) {
      String c1 = data[i];
      String? c2 = i + 1 < data.length ? data[i + 1] : null;
      if (c2 != null) {
        int index1 = charMap.indexOf(c1);
        int index2 = charMap.indexOf(c2);
        int combined = index1 * 45 + index2;
        String binary = combined.toRadixString(2);
        while (binary.length < 11) {
          binary = '0$binary';
        }
        bits += binary;
      } else {
        int index = charMap.indexOf(c1);
        String binary = index.toRadixString(2);
        while (binary.length < 6) {
          binary = '0$binary';
        }
        bits += binary;
      }
    }
    return bits;
  }

  String encodeByte(String data) {
    List<int> bytes = utf8.encode(data);
    String bits = '';
    for (var byte in bytes) {
      String binary = byte.toRadixString(2).padLeft(8, '0');
      bits += binary;
    }
    return bits;
  }

  String encodeData(String text, int version) {
    encodingMode mode = detectBestEncodingMode(text);
    Map<encodingMode, String> modeIndicators = {
      encodingMode.numreic: '0001',
      encodingMode.alphanumeric: '0010',
      encodingMode.byte: '0100',
      encodingMode.kanji: '1000',
    };
    String modeIndicator = modeIndicators[mode]!;
    int charCount = text.length;
    int charCountLength = getCharCountIndicatorLength(version, mode);
    String charCountBinary = charCount.toRadixString(2);
    while (charCountBinary.length < charCountLength) {
      charCountBinary = '0$charCountBinary';
    }
    String dataBits = '';
    switch (mode) {
      case encodingMode.numreic:
        dataBits = encodeNumeric(text);
        break;
      case encodingMode.alphanumeric:
        dataBits = encodeAlphanumeric(text);
        break;
      case encodingMode.byte:
        dataBits = encodeByte(text);
        break;
      case encodingMode.kanji:
        dataBits = '';
        break;
    }

    String encodedData = modeIndicator + charCountBinary + dataBits;
    int totalCodewords = getTotalCodewords(version);

    int requiredBits = totalCodewords * 8;
    int terminatorLength = min(4, requiredBits - encodedData.length);
    encodedData += ('0' * terminatorLength);

    if (encodedData.length % 8 != 0) {
      int padLength = 8 - (encodedData.length % 8);
      encodedData += ('0' * padLength);
    }
    List<String> padCodewords = ['11101100', '0001110001'];
    int padIndex = 0;
    while (encodedData.length < requiredBits) {
      encodedData += padCodewords[padIndex];
      padIndex = (padIndex + 1) % 2;
    }
    return encodedData;
  }

  int gfMultiply(int a, int b) {
    if (a == 0 || b == 0) return 0;
    int result = 0;
    int irreducible = 0x11D;
    for (int i = 0; i < 8; i++) {
      if ((b & (1 << i)) != 0) {
        int aShifted = a << i;
        for (int j = 7 + i; j >= 8; j--) {
          if ((aShifted & (1 << j)) != 0) {
            aShifted ^= irreducible << (j - 8);
          }
        }
        result ^= aShifted;
      }
    }
    return result & 0xFF;
  }

  List<List<int>> get gfMulTable =>
      List.generate(256, (i) => List.generate(256, (j) => gfMultiply(i, j)));

  List<int> generateGeneratorPoly(int degree) {
    List<int> poly = [1];
    for (int i = 0; i < degree; i++) {
      List<int> factor = [1, alphaPower(i)];
      List<int> newPoly = List.filled(poly.length + factor.length - 1, 0);
      for (int j = 0; j < poly.length; j++) {
        for (int k = 0; k < factor.length; k++) {
          newPoly[j + k] ^= gfMulTable[poly[j]][factor[k]];
        }
      }
      poly = newPoly;
    }
    return poly;
  }

  int alphaPower(int exp) {
    if (exp == 0) return 1;
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result = gfMulTable[result][2];
      if (result >= 256) {
        result ^= 0x11D;
      }
    }
    return result;
  }

  List<int> rsEncode(List<int> data, int errsum) {
    List<int> genPoly = generateGeneratorPoly(errsum);
    List<int> dividend = [...data, ...List.filled(errsum, 0)];
    for (int i = 0; i < data.length; i++) {
      int coef = dividend[i];
      if (coef != 0) {
        for (int j = 0; j < genPoly.length; j++) {
          dividend[i + j] ^= gfMulTable[coef][genPoly[j]];
        }
      }
    }
    return dividend.sublist(data.length);
  }

  Map getQrcodeBlocks(int version, String errorCorrectionLevel) {
    if (version == 1 && errorCorrectionLevel == 'L') {
      return {
        'count': 1,
        'blocks': [
          {"dataCodeCount": 16, "纠错码数量": 7},
        ],
      };
    }
    return {
      "count": 1,
      "blocks": [
        {"dataCodeCount": 16, "纠错码数量": 7},
      ],
    };
  }
}
