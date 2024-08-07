part of "link_utils.dart";

/// This class is only to be modified by package maintainers/contributors.
class LinkPreviewMain extends StatelessWidget {
  /// The uri/url text
  final String url;

  /// Constructor
  LinkPreviewMain({super.key, required this.url});

  final Map<String, bool> isFetchingLinkData = {"state": false};

  Future<LinkPreviewData> handleLinkFetching(String url) async {
    isFetchingLinkData['state'] = true;
    LinkPreviewData data = await LinkPreviewer(url: url).fetchLinkPreview(url);
    isFetchingLinkData['state'] = false;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
      child: FutureBuilder(
        future: handleLinkFetching(url),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && isFetchingLinkData['state'] == false) {
            return Card(
                child: snapshot.data?.fetchingState == DataFetchingState.failed
                    ? const Center(child: Text('Failed to load preview'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.data?.imageUrl != null)
                            Image.network(
                              snapshot.data!.imageUrl!,
                              errorBuilder: (context, error, stackTrace) {
                                return Container();
                              },
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (snapshot.data?.title != null)
                                  Text(snapshot.data?.title ?? url,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                if (snapshot.data?.description != null)
                                  Text(snapshot.data?.description ?? url,
                                      style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ));
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

}
