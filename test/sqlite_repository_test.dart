import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste_app_flutter/data/candidature_repository.dart';
import 'package:piste_app_flutter/models/candidature.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  test('Une nouvelle base est vide et accepte une première candidature',
      () async {
    final repo = SqliteCandidatureRepository(
        factory: databaseFactoryFfi, fichier: inMemoryDatabasePath);
    addTearDown(repo.fermer);
    expect(await repo.toutes(), isEmpty);
    await repo.enregistrer(Candidature(
        nomEntreprise: 'Première entreprise',
        poste: 'Stage',
        statut: Statut.envoyee));
    expect((await repo.toutes()).single.id, isNotNull);
  });
  test('Migration v1 puis création, édition et suppression entre réouvertures',
      () async {
    final dossier = await Directory.systemTemp.createTemp('piste_test');
    final fichier = '${dossier.path}/piste.db';
    final factory = databaseFactoryFfi;
    final db = await factory.openDatabase(fichier,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) async {
              await db.execute(
                  'CREATE TABLE candidatures(id INTEGER PRIMARY KEY AUTOINCREMENT, entreprise TEXT, poste TEXT, status TEXT, notes TEXT, url TEXT, date_creation TEXT, prochaine_relance TEXT)');
              await db.execute(
                  "INSERT INTO candidatures VALUES(1,'Atelier','Stage','entretien','','','2026-01-01',NULL)");
            }));
    await db.close();
    final repo =
        SqliteCandidatureRepository(factory: factory, fichier: fichier);
    addTearDown(() async {
      await repo.fermer();
      await dossier.delete(recursive: true);
    });
    final ancienne = (await repo.toutes()).single;
    expect(ancienne.dateModification, ancienne.dateCreation);
    await repo.enregistrer(Candidature(
        nomEntreprise: 'Atelier', poste: 'Mobile', statut: Statut.brouillon));
    await repo.fermer();
    final nouvelle = (await repo.toutes()).first;
    expect(nouvelle.id, isNot(ancienne.id));
    await repo.enregistrer(Candidature(
        id: nouvelle.id,
        nomEntreprise: 'Atelier',
        poste: nouvelle.poste,
        statut: Statut.offre,
        relance: DateTime(2027, 1, 5),
        dateCreation: nouvelle.dateCreation,
        notes: 'Rappeler',
        url: 'https://example.com'));
    await repo.fermer();
    final editee = (await repo.toutes()).first;
    expect(editee.statut, Statut.offre);
    expect(editee.relance, DateTime(2027, 1, 5));
    expect(editee.dateCreation, nouvelle.dateCreation);
    expect(editee.notes, 'Rappeler');
    await repo.supprimer(editee.id!);
    await repo.fermer();
    expect((await repo.toutes()).single.id, ancienne.id);
  });
}
