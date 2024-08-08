<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
<p align="center">
  <img alt="Chat Image" src="https://raw.githubusercontent.com/IsaiahTek/link_utils/main/images/link_utils_preview.png" />
</p>
A Flutter package for creating rich link previews and managing various URL utilities effortlessly.

[![Pub Version](https://img.shields.io/pub/v/link_utils)](https://pub.dev/packages/link_utils)
[![Pub Points](https://img.shields.io/pub/points/link_utils)](https://pub.dev/packages/link_utils/score)
[![Build Status](https://github.com/IsaiahTek/link_utils/workflows/build/badge.svg)](https://github.com/IsaiahTek/link_utils/actions)


## Features

- Generate rich link previews from URLs.
- Extract metadata such as title, description, and images.
- Validate and manipulate URLs easily.


## Getting Started
To get started with flutter_chatflow, check out the documentation for installation instructions, usage guides, and examples.

### Installation

Easiest way is to run the `flutter pub add flutter_chatflow`


## Usage


```dart
import 'package:flutter/material.dart';
import 'package:link_utils/link_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Link Utils Example App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();

  String? url;

  @override
  void initState() {
    _textEditingController.addListener(() {
      // `getUrls` is a util function used to search for urls in a given text
      String? url = getUrls(_textEditingController.text).firstOrNull;
      // By default, a change event is fired when the user taps different parts of the text field. So we ensure we're only setting the url when a user changes the first url text and not any other text
      if (this.url != url) {
        setState(() {
          this.url = url;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (url != null) LinkPreviewTile(url: url!),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              // In this example we've used a dynamic text field and we used a text editing controller.
              child: TextField(
                minLines: 1,
                maxLines: null,
                controller: _textEditingController,
                style: TextStyle(color: Theme.of(context).primaryColorLight),
              ),
            )
          ],
        ),
      ),
    );
  }
}

```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue on GitHub to discuss what you would like to change.

## License
This project is released under the [BSD license.](https://github.com/IsaiahTek/link_utils/blob/main/LICENSE)