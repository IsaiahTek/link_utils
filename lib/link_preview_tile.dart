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
      ?FutureBuilder(
        future: handleLinkFetching(widget.url),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              isFetchingLinkData['state'] == false) {
            return Card(
                child:
                    snapshot.data?.fetchingState == DataFetchingState.failed ||
                            snapshot.data == null
                        ? const Center(child: Text('Failed to load preview'))
                        : _PreviewWidgetTile(previewData: snapshot.data!));
          } else {
            return const CircularProgressIndicator();
          }
        },
      )
      : _PreviewWidgetTile(previewData: _previewData!),
    );
  }
}

class _PreviewWidgetTile extends StatelessWidget {
  final LinkPreviewData previewData;

  const _PreviewWidgetTile({required this.previewData});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (previewData.imageUrl != null)
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .3,
            height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
              child: Image.network(
                fit: BoxFit.fill,
                previewData.imageUrl!,
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
        ),
      ],
    );
  }
}
