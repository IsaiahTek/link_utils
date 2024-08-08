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
      title: 'Link Utils',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 19, 19, 19)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Link Utils Example'),
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
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                minLines: 1,
                maxLines: null,
                controller: _textEditingController,
                decoration: const InputDecoration(
                    hintText: "Enter a link here",
                    hintStyle: TextStyle(color: Colors.white)),
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                ),
              ),
            ),
            if (url != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Example of LinkPreviewTile",
                      style: TextStyle(fontSize: 22),
                    ),
                    LinkPreviewTile(url: url!),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "Example of LinkPreviewMain",
                      style: TextStyle(fontSize: 22),
                    ),
                    LinkPreviewMain(url: url!)
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
