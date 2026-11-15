import 'package:app_links/app_links.dart';

import '../../domain/ports/incoming_link_source.dart';

final class AppLinksIncomingLinkSource implements IncomingLinkSource {
  final Stream<Uri> _links;

  AppLinksIncomingLinkSource({Stream<Uri>? links})
      : _links = links ?? AppLinks().uriLinkStream;

  @override
  Stream<Uri> incomingLinks() => _links;
}
