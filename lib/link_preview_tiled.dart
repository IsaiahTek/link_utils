part of 'link_utils.dart';
/**
 * An exclusive open source project written by Engr., Isaiah Pius E.
 */

/// The widget displays the link preview image to the left and the title and descriptio/content to the right

/// This class is only to be modified by package maintainers/contributors.
class LinkPreviewTile extends StatefulWidget {
  /// The uri/url text
  final String url;

  /// Constructor
  const LinkPreviewTile({super.key, required this.url});

  @override
  State<LinkPreviewTile> createState() => _LinkPreviewTiledState();
}

class _LinkPreviewTiledState extends State<LinkPreviewTile> {
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
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.data?.imageUrl != null)
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .3,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(10),
                                ),
                                child: Image.network(
                                  fit: BoxFit.fill,
                                  snapshot.data!.imageUrl!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (snapshot.data?.title != null)
                                    Text(snapshot.data?.title ?? widget.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  if (snapshot.data?.description != null)
                                    Text(
                                        snapshot.data?.description ??
                                            widget.url,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14)),
                                ],
                              ),
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
