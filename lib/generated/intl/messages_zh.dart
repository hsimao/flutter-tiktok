// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(gender) => "登入";

  static String m1(nameOfTheApp) => "登入 ${nameOfTheApp} 帳號";

  static String m2(nameOfTheApp) => "註冊 ${nameOfTheApp}";

  static String m3(videoCount) => "創建個人檔案，關注其他帳戶，製作自己的影片等等。";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "alreadyHaveAnAccount":
            MessageLookupByLibrary.simpleMessage("已經有帳號了嗎？"),
        "appleButton": MessageLookupByLibrary.simpleMessage("使用 Apple 帳號"),
        "emailPasswordButton":
            MessageLookupByLibrary.simpleMessage("使用電子郵件和密碼"),
        "logIn": m0,
        "loginTitle": m1,
        "signUpTitle": m2,
        "singUpSubtitle": m3
      };
}
