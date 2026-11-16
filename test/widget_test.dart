import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste_app_flutter/main.dart';

import 'package:piste_app_flutter/models/candidature.dart';
import 'fake_repository.dart';

void main() {
  testWidgets('Réessayer une lecture en erreur', (tester) async {
    final repo = FakeCandidatureRepository()..echecLecture = true;
    await tester.pumpWidget(MyApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.text('Aucune candidature enregistrée.'), findsNothing);
    repo.echecLecture = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune candidature enregistrée.'), findsOneWidget);
  });

  testWidgets('Les statistiques comptent les candidatures par statut',
      (tester) async {
    final repo = FakeCandidatureRepository();
    for (final statut in [Statut.entretien, Statut.offre]) {
      await repo.enregistrer(Candidature(
          nomEntreprise: 'Atelier', poste: statut.name, statut: statut));
    }
    await tester.pumpWidget(MyApp(repository: repo));
    await tester.pumpAndSettle();
    expect(find.byType(Card), findsNWidgets(2));
    await tester.tap(find.text('Statistiques').last);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('Créer, modifier puis supprimer après confirmation',
      (tester) async {
    await tester.pumpWidget(MyApp(repository: FakeCandidatureRepository()));
    await tester.pumpAndSettle();
    Future<void> appuyer(String texte) async {
      final bouton = find.text(texte).last;
      await tester.ensureVisible(bouton);
      await tester.tap(bouton);
      await tester.pumpAndSettle();
    }

    await appuyer('Ajouter');
    await appuyer('Enregistrer');
    expect(find.text('Champ obligatoire'), findsNWidgets(2));
    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Poste'));
    final champs = find.byType(TextFormField);
    await tester.enterText(champs.at(0), 'Stage Flutter');
    await tester.enterText(champs.at(1), 'Atelier');
    final enregistrer = find.text('Enregistrer');
    await tester.ensureVisible(enregistrer);
    await tester.tap(enregistrer);
    await tester.tap(enregistrer, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Stage Flutter'), findsOneWidget);

    await appuyer('Stage Flutter');
    await appuyer('Modifier');
    expect(find.widgetWithText(TextFormField, 'Atelier'), findsOneWidget);
    await tester.enterText(champs.at(0), 'Stage mobile');
    await appuyer('Enregistrer');
    expect(find.text('Fiche candidature'), findsOneWidget);
    expect(find.text('Stage mobile'), findsOneWidget);
    await appuyer('Supprimer');
    await appuyer('Annuler');
    expect(find.text('Stage mobile'), findsOneWidget);
    await appuyer('Supprimer');
    await appuyer('Supprimer');
    expect(find.text('Piste'), findsOneWidget);
    expect(find.text('Atelier'), findsNothing);
    expect(find.byType(Card), findsNothing);
  });
}
