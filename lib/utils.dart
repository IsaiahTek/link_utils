part of "link_utils.dart";

/// This class is only to be modified by package maintainers/contributors.
/// 
/// 
enum DataFetchingState{
  success,
  failed,
  fetching,
}

class LinkPreviewData{
  String title;
  String description;
  String? imageUrl;
  String? originatingLink;
  DataFetchingState fetchingState;

  LinkPreviewData({
    required this.title,
    required this.description,
    this.imageUrl,
    this.originatingLink,
    required this.fetchingState
  });

  @override
  String toString() {
    return "LindPreviewData(title:$title, description:$description, imageUrl:$imageUrl, originating link ($originatingLink) State($fetchingState))";
  }
}

class LinkPreviewer {
  String? _title;
  String? _description;
  String? _imageUrl;
  bool loading = true;
  bool _error = false;
  dynamic get error =>_error;

  final String url;

  LinkPreviewer({
    required this.url
  });

  Future<LinkPreviewData> fetchLinkPreview(String url) {
    LinkPreviewData(description: "", title: "", fetchingState: DataFetchingState.fetching);
    return _fetchLinkPreview(url).then(
      (onValue){
        return onValue == DataFetchingState.success 
        ? LinkPreviewData(title: _title!, description: _description!, imageUrl: _imageUrl, originatingLink: url, fetchingState: DataFetchingState.success)
        : LinkPreviewData(title: "", description: "", fetchingState: DataFetchingState.failed);
      },
      onError: (err)=>LinkPreviewData(title: "", description: "", fetchingState: DataFetchingState.failed),
    );
  }
  
  Future<DataFetchingState> _fetchLinkPreview(String url) async {
    loading = true;
    _error = false;

    try {
      // Add http protocol if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
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
        _error = true;
        throw Error();
      }
    } catch (e) {
      _error = true;
      throw Error();
    } finally {
      loading = false;
    }
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
        if (tag.contains('property="og:description"') || tag.contains('name="description"')) {
          final content = RegExp(r'content="([^"]+)"').firstMatch(tag)?.group(1);
          if (content != null) {
            _description = content;
          }
        }
        if (tag.contains('property="og:image"') ||
            tag.contains('property="twitter:image"') ||
            tag.contains('name="twitter:image"')) {
          final content = RegExp(r'content="([^"]+)"').firstMatch(tag)?.group(1);
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
  String urlPattern = r'(?:(?:https?|ftp):\/\/)?(?:[\w-]+\.)+[a-z]{2,}(?:\/\S*)?';
  final regex = RegExp(urlPattern, caseSensitive: false);
  final matches = regex.allMatches(text);

  return matches.map((match) => match.group(0)!).toList();
}
Future<bool> canLaunch(String url) async {
  try {
    final uri = Uri.parse(url);
    return await HttpClient().getUrl(uri).then((_) => true).catchError((_) => false);
  } catch (e) {
    return false;
  }
}

Future<void> launch(String url) async {
  if (await canLaunch(url)) {
    print('Launching $url');
    // Here you would launch the URL in a webview or browser.
    // Since we can't launch URLs directly in this example, we just print the URL.
  } else {
    print('Could not launch $url');
  }
}