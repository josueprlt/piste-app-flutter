import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/candidature.dart';

abstract interface class CandidatureRepository {
  Future<List<Candidature>> toutes();
  Future<void> enregistrer(Candidature candidature);
  Future<void> supprimer(int id);
  Future<void> fermer();
}

class SqliteCandidatureRepository implements CandidatureRepository {
  SqliteCandidatureRepository({DatabaseFactory? factory, this.fichier})
      : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? fichier;
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final chemin =
        fichier ?? path.join(await _factory.getDatabasesPath(), 'piste.db');
    return _database = await _factory.openDatabase(chemin,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, _) => db.execute('''
        CREATE TABLE candidatures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          entreprise TEXT NOT NULL, poste TEXT NOT NULL, status TEXT NOT NULL,
          notes TEXT NOT NULL, url TEXT NOT NULL,
          date_creation TEXT NOT NULL, date_modification TEXT NOT NULL,
          prochaine_relance TEXT
        )
      '''),
          onUpgrade: (db, ancienneVersion, _) async {
            if (ancienneVersion < 2) {
              await db.execute(
                  "ALTER TABLE candidatures ADD COLUMN date_modification TEXT NOT NULL DEFAULT ''");
              await db.execute(
                  'UPDATE candidatures SET date_modification = date_creation');
            }
          },
        ));
  }

  @override
  Future<List<Candidature>> toutes() async {
    final lignes = await (await _db)
        .query('candidatures', orderBy: 'date_modification DESC, id DESC');
    return lignes
        .map((ligne) => Candidature(
              id: ligne['id'] as int,
              nomEntreprise: ligne['entreprise'] as String,
              poste: ligne['poste'] as String,
              statut: Statut.values.byName(ligne['status'] as String),
              notes: ligne['notes'] as String,
              url: ligne['url'] as String,
              relance: ligne['prochaine_relance'] == null
                  ? null
                  : DateTime.parse(ligne['prochaine_relance'] as String),
              dateCreation: DateTime.parse(ligne['date_creation'] as String),
              dateModification:
                  DateTime.parse(ligne['date_modification'] as String),
            ))
        .toList();
  }

  @override
  Future<void> enregistrer(Candidature candidature) async {
    final db = await _db;
    final valeurs = {
      'entreprise': candidature.nomEntreprise,
      'poste': candidature.poste,
      'status': candidature.statut.name,
      'notes': candidature.notes,
      'url': candidature.url,
      'date_creation': candidature.dateCreation.toIso8601String(),
      'date_modification': candidature.dateModification.toIso8601String(),
      'prochaine_relance': candidature.relance?.toIso8601String(),
    };
    if (candidature.id == null) {
      await db.insert('candidatures', valeurs);
    } else if (await db.update('candidatures', valeurs,
            where: 'id = ?', whereArgs: [candidature.id]) !=
        1) {
      throw StateError('Candidature introuvable');
    }
  }

  @override
  Future<void> supprimer(int id) async {
    final db = await _db;
    if (await db.delete('candidatures', where: 'id = ?', whereArgs: [id]) !=
        1) {
      throw StateError('Candidature introuvable');
    }
  }

  @override
  Future<void> fermer() async {
    await _database?.close();
    _database = null;
  }
}
