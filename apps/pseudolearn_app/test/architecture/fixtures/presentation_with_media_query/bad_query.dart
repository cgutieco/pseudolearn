class BuildContext {}

class MediaQuery {
  static void of(BuildContext context) {}
}

void queryWindow(BuildContext context) {
  MediaQuery.of(context);
}
