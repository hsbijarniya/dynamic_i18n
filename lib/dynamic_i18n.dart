library dynamic_i18n;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String _reqUrl = '';
Map<String, String> _reqHeaders = {};
int totalPendingRequests = 0;

Map globalTranslations = {};
String _sourceLocale = 'en';
String _targetLocale = 'en';
List<String> _availableLocales = [];

Future fetchSingleTranslation(sourceText, targetLocale) {
  totalPendingRequests++;

  return http
      .post(
    Uri.parse(_reqUrl + '/' + targetLocale),
    body: {
      'en': sourceText,
      'target': targetLocale,
    },
    headers: _reqHeaders,
  )
      .then((res) {
    String hash = md5.convert(utf8.encode(sourceText)).toString();

    Map body = jsonDecode(utf8.decode(res.bodyBytes));

    globalTranslations[hash] = body[targetLocale];
    // print('\nfetched data of ' + text);
    // print(res[targetLocale]);

    totalPendingRequests--;

    return body[targetLocale];
  });
}

class I18n {
  late dynamic instance;

  I18n(this.instance);

  get(text, {Map vars = const {}}) {
    String hash = md5.convert(utf8.encode(text)).toString();

    if (globalTranslations[hash] == null) {
      // obtain translation
      fetchSingleTranslation(text, _targetLocale).then((res) {
        if (totalPendingRequests == 0) {
          instance.setState(() {});
        }
      });
    }

    return globalTranslations[hash] ?? text;
  }

  static init({
    required String url,
    Map<String, String>? headers,
    String sourceLocale = 'en',
    String? locale,
    List<String>? locales,
  }) {
    _reqUrl = url;
    _reqHeaders = headers ?? {};
    _sourceLocale = sourceLocale;
    _targetLocale = locale ?? 'en';
    _availableLocales = locales ?? ['en'];

    Uri fetchUri = Uri.parse(_reqUrl + '/' + _targetLocale + '.json');

    http.get(fetchUri, headers: _reqHeaders).then((res) {
      List body = jsonDecode(utf8.decode(res.bodyBytes));

      for (int i = 0; i < body.length; i++) {
        String hash = md5.convert(utf8.encode(body[i]['en'])).toString();

        globalTranslations[hash] = body[i][_targetLocale];
      }
    });
  }

  static Widget builder(
    String sourceText,
    Widget Function(String translatedText) builder,
  ) {
    String hash = md5.convert(utf8.encode(sourceText)).toString();

    // obtain translation
    Future req = fetchSingleTranslation(sourceText, _targetLocale);

    return FutureBuilder(
      future: req,
      builder: (context, snapshot) {
        return builder(globalTranslations[hash]);
      },
    );
  }

  static Widget childBuilder(
    String sourceText,
    Widget Function(String translatedText, Widget child) builder,
    Widget child,
  ) {
    String hash = md5.convert(utf8.encode(sourceText)).toString();

    // obtain translation
    Future req = fetchSingleTranslation(sourceText, _targetLocale);

    return FutureBuilder(
      future: req,
      builder: (context, snapshot) {
        return builder(globalTranslations[hash], child);
      },
    );
  }

  static Widget text(String sourceText) {
    return I18n.builder(sourceText, (translatedText) => Text(translatedText));
  }
}

abstract class I18nState<T extends StatefulWidget> extends State<T> {
  late I18n locale;
  late Function i18n;

  @override
  void initState() {
    super.initState();

    locale = I18n(this);
    i18n = locale.get;
  }
}
