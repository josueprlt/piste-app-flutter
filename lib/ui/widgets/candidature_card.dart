import 'package:flutter/material.dart';
import '../../models/candidature.dart';
import 'statut_badge.dart';

class CandidatureCard extends StatelessWidget {
  const CandidatureCard(
      {super.key, required this.candidature, required this.onTap});
  final Candidature candidature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.business_outlined, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(candidature.poste,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(candidature.nomEntreprise,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const SizedBox(height: 12),
                    StatutBadge(candidature.statut),
                  ])),
              const Icon(Icons.chevron_right, size: 20),
            ]),
          ),
        ),
      );
}
