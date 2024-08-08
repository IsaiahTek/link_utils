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
  LinkPreviewData? _previewData;

  @override
  initState() {
    previewer = LinkPreviewer(url: widget.url);
    previewer.previewData?.then((onValue) {
      if (onValue != null) {
        _previewData = onValue;
      }
    });
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
      child: _previewData == null
          ? FutureBuilder(
              future: handleLinkFetching(widget.url),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    isFetchingLinkData['state'] == false) {
                  return Card(
                      child: snapshot.data?.fetchingState ==
                                  DataFetchingState.failed ||
                              snapshot.data == null
                          ? const Center(child: Text('Failed to load preview'))
                          : _PreviewWidget(
                              previewData: snapshot.data!,
                            ));
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          // : Text("JUST TESTING")
          : _PreviewWidget(previewData: _previewData!),
    );
  }
}

class _PreviewWidget extends StatelessWidget {
  final LinkPreviewData previewData;

  const _PreviewWidget({required this.previewData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (previewData.imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              previewData.imageUrl!,
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
              if (previewData.title.isNotEmpty)
                Text(previewData.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              if (previewData.description.isNotEmpty)
                Text(previewData.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
