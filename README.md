Dynamically load translation in your app.

## Getting started
Initiate I18n in your dart's main() {}

```dart
void main() {
    // ...

    I18n.init(
        url: 'https://www.example.com',
        locale: 'hi',
        locales: ['en', 'hi', 'pa'],
    );

    // ... 
}
```

Now you can use I18n.builder anywhere in your code

```dart
Column(
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
```

## Server Setup

Set your server to respond in this way.

Request Method: GET  
Request URL: https://www.example.com/hi.json  
  
Response  
Content-Type: application/json  
  
```json
[
    {'en': 'How are you ?', 'hi': 'आप कैसे हो ?'},
    {'en': 'Who am I ?', 'hi': 'मैं कौन हूँ ?'},
]
```
  
For single translation request library will send POST request in this format to url you have provided in I18n.init, according to above example it will be

Request Method: POST  
Request URL: https://www.example.com/hi  
  
```json
{
    'en': sourceText,
    'target': targetLocale,
}
```
  
Response  
Content-Type: application/json  
  
```json
{'en': 'How are you ?', 'hi': 'आप कैसे हो ?'}
```