import 'package:flutter_test/flutter_test.dart';

import 'package:link_utils/link_utils.dart';

void main() {
  test('LinkPreviewData Fetch test', () async {
    String url = 'pub.dev/packages/flutter_chatflow';
    LinkPreviewer previewer = LinkPreviewer(url: url);
    expect((await previewer.previewData).toString(),
        'LindPreviewData(title:flutter_chatflow | Flutter package, description:A versatile chat solution for Flutter apps, offering fast messaging, customizable UI, user management, media sharing, and group chats. Ideal for building robust communication apps, imageUrl:https://pub.dev/static/hash-6pt8ae32/img/pub-dev-icon-cover-image.png, originating link ($url) State(${DataFetchingState.success}))');
  });

  test('LinkPreviewData Fetch test', () async {
    String url = 'examples.com';
    LinkPreviewer previewer = LinkPreviewer(url: url, useOmittedHttp: false);
    expect((await previewer.previewData).toString(),
        'LindPreviewData(title:, description:, imageUrl:null, originating link ($url) State(${DataFetchingState.failed}))');
  });
}
