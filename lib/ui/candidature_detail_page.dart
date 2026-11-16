import 'widgets/statut_badge.dart';
import 'package:flutter/material.dart';
import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_form_page.dart';

class CandidatureDetailPage extends StatefulWidget {
  const CandidatureDetailPage(
      {super.key, required this.controller, required this.candidature});
  final CandidatureController controller;
  final Candidature candidature;

  @override
  State<CandidatureDetailPage> createState() => _CandidatureDetailPageState();
}

class _CandidatureDetailPageState extends State<CandidatureDetailPage> {
  late Candidature candidature = widget.candidature;

  Future<void> _modifier() async {
    final resultat = await Navigator.push<Candidature>(
        context,
        MaterialPageRoute(
          builder: (_) => CandidatureFormPage(
              controller: widget.controller, initiale: candidature),
        ));
    if (mounted && resultat != null) setState(() => candidature = resultat);
  }

  bool _suppression = false;

  Future<void> _supprimer() async {
    final accord = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Supprimer cette candidature ?'),
              content:
                  Text('${candidature.poste} · ${candidature.nomEntreprise}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Supprimer')),
              ],
            ));
    if (!mounted || accord != true) return;
    if (_suppression) return;
    setState(() => _suppression = true);
    try {
      await widget.controller.supprimer(candidature);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _suppression = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suppression impossible. Réessaie.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context).formatShortDate;
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche candidature')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.business_outlined, size: 32),
                        const SizedBox(height: 20),
                        Text(candidature.poste,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(candidature.nomEntreprise,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                        const SizedBox(height: 20),
                        StatutBadge(candidature.statut),
                      ],
                    ))),
            const SizedBox(height: 28),
            Text('Suivi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Création'),
                subtitle: Text(date(candidature.dateCreation))),
            ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Dernière modification'),
                subtitle: Text(date(candidature.dateModification))),
            if (candidature.relance != null)
              ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Relance'),
                  subtitle: Text(date(candidature.relance!))),
            if (candidature.url.isNotEmpty)
              ListTile(
                  title: const Text('URL'), subtitle: Text(candidature.url)),
            if (candidature.notes.isNotEmpty)
              ListTile(
                  title: const Text('Notes'),
                  subtitle: Text(candidature.notes)),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _suppression ? null : _modifier,
                child: const Text('Modifier')),
            const SizedBox(height: 8),
            TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error),
                onPressed: _suppression ? null : _supprimer,
                child: const Text('Supprimer')),
          ])),
    );
  }
}
