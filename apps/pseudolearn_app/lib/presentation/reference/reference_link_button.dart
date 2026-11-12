import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/reference/reference_index_cubit.dart';
import '../../application/reference/reference_index_state.dart';
import '../l10n/generated/app_localizations.dart';
import 'reference_edition_resolver.dart';

final class ReferenceLinkButton extends StatefulWidget {
  final String? cardId;
  final String? diagnosticCode;

  const ReferenceLinkButton.card(String id, {super.key})
    : cardId = id,
      diagnosticCode = null;

  const ReferenceLinkButton.diagnostic(String code, {super.key})
    : cardId = null,
      diagnosticCode = code;

  @override
  State<ReferenceLinkButton> createState() => _ReferenceLinkButtonState();
}

final class _ReferenceLinkButtonState extends State<ReferenceLinkButton> {
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _available =
        context
            .findAncestorWidgetOfExactType<
              BlocProvider<ReferenceIndexCubit>
            >() !=
        null;
    if (_available) {
      context.read<ReferenceIndexCubit>().load(
        currentReferenceEdition(context),
      );
    }
  }

  String? _target(ReferenceIndexState state) {
    final card = widget.cardId;
    if (card != null) return state.links.sectionForCard(card);
    final code = widget.diagnosticCode;
    return code == null ? null : state.links.sectionForDiagnostic(code);
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();
    return BlocBuilder<ReferenceIndexCubit, ReferenceIndexState>(
      builder: (context, state) {
        final target = _target(state);
        if (target == null) return const SizedBox.shrink();
        return TextButton.icon(
          icon: const Icon(Icons.menu_book_outlined),
          label: Text(
            AppLocalizations.of(context)!.referenceOpenInSpecification,
          ),
          onPressed: () => context.push('/conocimiento/especificacion/$target'),
        );
      },
    );
  }
}
