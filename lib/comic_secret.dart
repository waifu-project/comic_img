import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'comic_const.dart';

int getNum(int detailID, String picID) {
  if (detailID <= kLowChunkDepID) {
    return kLowChunkDepDefaultNum;
  }
  String targetID = '$detailID$picID';
  String secret = md5.convert(utf8.encode(targetID)).toString();
  String secretLast = secret[secret.length - 1];
  int code = secretLast.codeUnitAt(0);
  int syb = code % 10;
  if (syb >= kChunkNumMap.length) return kLowChunkDepDefaultNum;
  return kChunkNumMap[syb];
}
