part of "link_utils.dart";

/// This class is only to be modified by package maintainers/contributors.
class LinkPreviewMain extends StatefulWidget {
  /// The uri/url text
  final String url;

  /// Constructor
  const LinkPreviewMain({super.key, required this.url});

  @override
  State<LinkPreviewMain> createState() => _LinkPreviewMainState();
}

class _LinkPreviewMainState extends State<LinkPreviewMain> {
  /// Flag to watch the fetching state of data.
  final Map<String, bool> isFetchingLinkData = {"state": false};

  late LinkPreviewer previewer;

  @override
  initState() {
    previewer = LinkPreviewer(url: widget.url);
    super.initState();
  }

  /// Called to fetch data for a given link.
  Future<LinkPreviewData?> handleLinkFetching(String url) async {
    isFetchingLinkData['state'] = true;
    LinkPreviewData? data = url != widget.url
        ? await previewer.fetchLinkPreviewData(url)
        : await previewer.previewData;
    isFetchingLinkData['state'] = false;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(widget.url)) {
          await launch(widget.url);
        }
      },
      child: FutureBuilder(
        future: handleLinkFetching(widget.url),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              isFetchingLinkData['state'] == false) {
            return Card(
                child: snapshot.data?.fetchingState == DataFetchingState.failed
                    ? const Center(child: Text('Failed to load preview'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.data?.imageUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              child: Image.network(
                                snapshot.data!.imageUrl!,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container();
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (snapshot.data?.title != null)
                                  Text(snapshot.data?.title ?? widget.url,
                                  maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                if (snapshot.data?.description != null)
                                  Text(snapshot.data?.description ?? widget.url,
                                      maxLines: 4,
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
