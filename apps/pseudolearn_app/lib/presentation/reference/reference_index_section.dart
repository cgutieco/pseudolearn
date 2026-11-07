import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/reference/reference_index_cubit.dart';
import '../../application/reference/reference_index_state.dart';
import 'reference_edition_resolver.dart';
import 'reference_index_view.dart';

final class ReferenceIndexSection extends StatelessWidget {
  const ReferenceIndexSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferenceIndexCubit, ReferenceIndexState>(
      builder: (context, state) => ReferenceIndexView(
        state: state,
        onOpenSection: (id) => context.push('/conocimiento/especificacion/$id'),
        onRetry: () => context.read<ReferenceIndexCubit>().load(
          currentReferenceEdition(context),
        ),
      ),
    );
  }
}
