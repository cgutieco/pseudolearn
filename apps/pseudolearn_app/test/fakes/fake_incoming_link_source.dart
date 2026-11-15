import 'dart:async';
import 'package:pseudolearn_app/domain/ports/incoming_link_source.dart';

final class FakeIncomingLinkSource implements IncomingLinkSource {
  final _controller = StreamController<Uri>.broadcast();

  void emit(Uri link) => _controller.add(link);

  @override
  Stream<Uri> incomingLinks() => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
