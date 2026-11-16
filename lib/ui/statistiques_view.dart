import 'package:flutter/material.dart';
import '../models/candidature.dart';
import 'widgets/statut_badge.dart';

class StatistiquesView extends StatelessWidget {
  const StatistiquesView({super.key, required this.candidatures});
  final List<Candidature> candidatures;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text('Votre progression',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total des candidatures'),
              const SizedBox(height: 8),
              Text('${candidatures.length}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700)),
            ]),
          )),
          const SizedBox(height: 28),
          Text('Répartition par statut',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          for (final statut in Statut.values) _repartition(context, statut),
        ],
      );

  Widget _repartition(BuildContext context, Statut statut) {
    final nombre = candidatures.where((c) => c.statut == statut).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(statut.libelle)),
          Text('$nombre', style: Theme.of(context).textTheme.titleMedium),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: candidatures.isEmpty ? 0 : nombre / candidatures.length,
          color: statut.couleur,
          backgroundColor: Theme.of(context).colorScheme.surface,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ]),
    );
  }
}
