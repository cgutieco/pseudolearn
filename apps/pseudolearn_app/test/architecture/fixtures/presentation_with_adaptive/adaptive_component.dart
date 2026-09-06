class Switch {
  static void adaptive({required bool value}) {}
}

void renderSwitch() {
  Switch.adaptive(value: true);
}
