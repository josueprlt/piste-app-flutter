import 'package:flutter/material.dart';
import '../../models/candidature.dart';

extension StatutPresentation on Statut {
  String get libelle => switch (this) {
        Statut.brouillon => 'Brouillon',
        Statut.envoyee => 'Envoyée',
        Statut.entretien => 'Entretien',
        Statut.offre => 'Offre',
        Statut.refusee => 'Refusée',
      };

  Color get couleur => switch (this) {
        Statut.brouillon => const Color(0xFFB6C5D3),
        Statut.envoyee => const Color(0xFF8CC5FF),
        Statut.entretien => const Color(0xFFF4CD86),
        Statut.offre => const Color(0xFF72DCC0),
        Statut.refusee => const Color(0xFFFFA7B2),
      };
}

class StatutBadge extends StatelessWidget {
  const StatutBadge(this.statut, {super.key});
  final Statut statut;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: statut.couleur.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(statut.libelle,
            style: TextStyle(
                color: statut.couleur,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}
