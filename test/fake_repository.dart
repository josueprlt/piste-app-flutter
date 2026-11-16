import 'package:piste_app_flutter/data/candidature_repository.dart';
import 'package:piste_app_flutter/models/candidature.dart';

class FakeCandidatureRepository implements CandidatureRepository {
  final _lignes = <int, Candidature>{};
  int _prochainId = 1;
  bool echecLecture = false;

  @override
  Future<List<Candidature>> toutes() async {
    if (echecLecture) throw StateError('Erreur de lecture simulée');
    return _lignes.values.toList();
  }

  @override
  Future<void> enregistrer(Candidature c) async {
    final id = c.id ?? _prochainId++;
    _lignes[id] = Candidature(
        id: id,
        nomEntreprise: c.nomEntreprise,
        poste: c.poste,
        statut: c.statut,
        relance: c.relance,
        url: c.url,
        notes: c.notes,
        dateCreation: c.dateCreation,
        dateModification: c.dateModification);
  }

  @override
  Future<void> supprimer(int id) async => _lignes.remove(id);
  @override
  Future<void> fermer() async {}
}
