import '../model/agent/reply_document.dart';

abstract interface class ReplyMarkdownReader {
  ReplyDocument read(String markdown);
}
