import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'contact_support_view.dart';

final class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContactSupportView(onBack: () => context.pop());
  }
}
