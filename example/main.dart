import 'package:flutter/material.dart';
import 'package:dynamic_i18n/dynamic_i18n.dart';

// Stateful widget example 1
// if translation exists then it will be returned otherwise
// setState will be called after translation fetch
class SomeStatefulWidget extends StatefulWidget {
  const SomeStatefulWidget({Key? key}) : super(key: key);

  @override
  _SomeStatefulWidgetState createState() => _SomeStatefulWidgetState();
}

class _SomeStatefulWidgetState extends State<SomeStatefulWidget> {
  late I18n locale;

  @override
  initState() {
    locale = I18n(this);

    super.initState();
  }

  @override
  build(BuildContext context) {
    return Text(locale.get('Hello world'));
  }
}

// Stateful widget example 2
// by extending I18nState you can remove boilerplate
class AnotherStatefulWidget extends StatefulWidget {
  const AnotherStatefulWidget({Key? key}) : super(key: key);

  @override
  _AnotherStatefulWidgetState createState() => _AnotherStatefulWidgetState();
}

class _AnotherStatefulWidgetState extends I18nState<AnotherStatefulWidget> {
  @override
  build(BuildContext context) {
    return Text(i18n('Hello world'));
  }
}

// Stateless widget example
class SomeStatelessWidget extends StatelessWidget {
  const SomeStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // example 1: for Text
        I18n.text('Who am I ?'), // Text('मैं कौन हूँ ?')

        // example 2: with builder
        // first build with given locale
        // rebuild after translation fetching
        I18n.builder('Who am I ?', (translatedText) {
          return Text(translatedText);
        }),

        // example 3: with childBuilder
        I18n.childBuilder(
          'Who am I ?',
          (translatedText, child) {
            return Column(
              children: [
                Text(translatedText),
                child, // same on both first and second build
              ],
            );
          },
          Container(), // will be reused in rebuild
        ),
      ],
    );
  }
}
