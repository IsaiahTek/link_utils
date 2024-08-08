part of "link_utils.dart";

/// This class is only to be modified by package maintainers/contributors.
///
///
enum DataFetchingState {
  /// Success state
  success,

  /// Failed state
  failed,

  /// Fetching state
  fetching,
}

/// Data fetched from the link
class LinkPreviewData {
  /// Title of the url
  String title;

  /// Description text of the url
  String description;

  /// [Optional]
  ///
  /// Image url of the url
  String? imageUrl;

  /// [Optional]
  ///
  /// Url for which preview data was fetched
  String? originatingLink;

  /// Fetching state of the transaction
  DataFetchingState fetchingState;

  /// Initialization
  LinkPreviewData(
      {required this.title,
      required this.description,
      this.imageUrl,
      this.originatingLink,
      required this.fetchingState});

  @override
  String toString() {
    return "LindPreviewData(title:$title, description:$description, imageUrl:$imageUrl, originating link ($originatingLink) State($fetchingState))";
  }
}

/// LinkPreview handles
class LinkPreviewer {
  String? _title;
  String? _description;
  String? _imageUrl;

  /// The data fetched.
  Future<LinkPreviewData?>? previewData;

  /// The url for which the preview data should be fetched.
  final String url;

  /// [Optional]
  ///
  /// If set to false, urls such as `example.com` without http:// or https:// won't be consider a valid link.
  final bool? useOmittedHttp;

  /// Initialize the fetch data.
  ///
  /// When the data is fetched, the `previewData` would change from null to the data fetched on success.
  ///
  /// If the the next call using the `fetchLinkPreviewData(url)` method returns an error, the `previewData` would change to null.
  LinkPreviewer({required this.url, this.useOmittedHttp = true}) {
    fetchLinkPreviewData(url);
  }

  /// LinkPreviewer method to handle fetching and returning link preview data.
  ///
  /// The return type is a future of `LinkPreviewData`.
  Future<LinkPreviewData?> fetchLinkPreviewData(String url) async {
    previewData = _fetchLinkPreviewData(url);
    return previewData;
  }

  Future<LinkPreviewData?> _fetchLinkPreviewData(String url) async {
    return _fetchLinkPreview(url).then(
      (onValue) {
        return onValue == DataFetchingState.success
            ? LinkPreviewData(
                title: _title!,
                description: _description!,
                imageUrl: _imageUrl,
                originatingLink: url,
                fetchingState: DataFetchingState.success)
            : null;
      },
      onError: (err) => LinkPreviewData(
          title: "",
          description: "",
          originatingLink: url,
          fetchingState: DataFetchingState.failed),
    );
  }

  /// Because `fetchLinkPreviewData` fetches and updates `previewData` we've provided this method to use for checking a url preview data without updating the `previewData` property.
  ///
  /// This might be helpful in situations you only want to know if there's a data for the link before taking any action without modifying the `previewData` of the object.
  Future<LinkPreviewData?> checkLinkPreviewData(String url) {
    return _fetchLinkPreviewData(url);
  }

  /// Call this to update `previewData` if you ever need to.
  void updatePreviewData(LinkPreviewData data) {
    previewData = Future.value(data);
  }

  Future<DataFetchingState> _fetchLinkPreview(String url) async {
    try {
      // Add http protocol if missing
      bool useMissingHttpLink = useOmittedHttp ?? true;
      if (!url.startsWith('http://') &&
          !url.startsWith('https://') &&
          useMissingHttpLink) {
        url = 'http://$url';
      }

      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final contents = StringBuffer();
        await for (var data in response.transform(utf8.decoder)) {
          contents.write(data);
        }
        final document = contents.toString();
        _parseHtml(document);
        return DataFetchingState.success;
      } else {
        throw Error();
      }
    } catch (e) {
      throw Error();
    } finally {}
  }

  void _parseHtml(String document) {
    final titleStart = document.indexOf('<title>');
    final titleEnd = document.indexOf('</title>');
    if (titleStart != -1 && titleEnd != -1) {
      _title = document.substring(titleStart + 7, titleEnd);
    } else {
      _title = 'No title found';
    }

    final metaTags = RegExp(r'<meta[^>]+>');
    final matches = metaTags.allMatches(document);

    for (final match in matches) {
      final tag = match.group(0);
      if (tag != null) {
        if (tag.contains('property="og:description"') ||
            tag.contains('name="description"')) {
          final content =
              RegExp(r'content="([^"]+)"').firstMatch(tag)?.group(1);
          if (content != null) {
            _description = content;
          }
        }
        if (tag.contains('property="og:image"') ||
            tag.contains('property="twitter:image"') ||
            tag.contains('name="twitter:image"')) {
          final content =
              RegExp(r'content="([^"]+)"').firstMatch(tag)?.group(1);
          if (content != null) {
            _imageUrl = content;
          }
        }
      }
    }

    if (_description == null || _description!.isEmpty) {
      _description = 'No description found';
    }

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      _imageUrl = null; // No image URL found
    }
  }
}

/// Util function to detect urls in a text. Feel free to use if you need it!
List<String> getUrls(String text) {
  return _getUrls(text);
}

List<String> _getUrls(String text) {
  String urlPattern =
      r'(?:(?:https?|ftp):\/\/)?(?:[\w-]+\.)+[a-z]{2,}(?:\/\S*)?';
  final regex = RegExp(urlPattern, caseSensitive: false);
  final matches = regex.allMatches(text);

  return matches.map((match) => match.group(0)!).toList();
}

/// Check if the passed in data is actually a real url.
///
/// Returns true if it's a real url otherwise false
Future<bool> canLaunch(String url) async {
  return _canLaunch(url);
}

Future<bool> _canLaunch(String url) async {
  try {
    final uri = Uri.parse(url);
    return await HttpClient()
        .getUrl(uri)
        .then((_) => true)
        .catchError((_) => false);
  } catch (e) {
    return false;
  }
}

/// A util to launch url.
Future<void> launch(String url) async {
  if (await canLaunch(url)) {
    if (kDebugMode) {
      print('Launching $url');
    }
    // Here we would launch the URL in a webview or browser.
    // Since we haven't implemented the launching of url yet, we just print the URL.
  } else {
    // Here we should throw or return an error. We just print for now.
    if (kDebugMode) {
      print('Could not launch $url');
    }
  }
}
