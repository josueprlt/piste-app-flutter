import 'package:flutter/material.dart';
import 'statistiques_view.dart';
import 'widgets/candidature_card.dart';
import '../state/candidature_controller.dart';
import 'candidature_detail_page.dart';
import 'candidature_form_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key, required this.controller});
  final CandidatureController controller;

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  int _onglet = 0;

  Widget _contenu() {
    final controller = widget.controller;
    switch (controller.etat) {
      case EtatChargement.chargement:
        return const Center(child: CircularProgressIndicator());
      case EtatChargement.erreur:
        return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Impossible d’accéder aux candidatures.'),
          TextButton(
              onPressed: controller.charger, child: const Text('Réessayer')),
        ]));
      case EtatChargement.vide:
      case EtatChargement.succes:
        break;
    }

    final toutes = controller.candidatures;

    if (_onglet == 1) return StatistiquesView(candidatures: toutes);
    if (toutes.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.work_outline,
              size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text('Aucune candidature enregistrée.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
              'Ajoutez votre première candidature pour commencer votre suivi.',
              textAlign: TextAlign.center),
        ]),
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: toutes.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mes candidatures',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                  '${toutes.length} candidature${toutes.length > 1 ? 's' : ''} à suivre',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          );
        }
        final candidature = toutes[index - 1];
        return CandidatureCard(
            candidature: candidature,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CandidatureDetailPage(
                        controller: controller, candidature: candidature))));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_onglet == 0 ? Icons.work_outline : Icons.bar_chart),
            const SizedBox(width: 8),
            Text(_onglet == 0 ? 'Piste' : 'Statistiques',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListenableBuilder(
          listenable: widget.controller, builder: (_, __) => _contenu()),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _onglet,
          onTap: (i) => setState(() => _onglet = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined), label: 'Statistiques'),
          ]),
      floatingActionButton: _onglet == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CandidatureFormPage(controller: widget.controller))),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
    );
  }
}
