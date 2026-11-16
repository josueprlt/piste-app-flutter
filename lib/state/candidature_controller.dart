import 'package:flutter/foundation.dart';
import '../data/candidature_repository.dart';
import '../models/candidature.dart';

enum EtatChargement { chargement, vide, succes, erreur }

class CandidatureController extends ChangeNotifier {
  CandidatureController(this.repository);
  final CandidatureRepository repository;
  List<Candidature> _candidatures = [];
  List<Candidature> get candidatures => List.unmodifiable(_candidatures);
  EtatChargement etat = EtatChargement.chargement;
  bool _occupe = false;

  Future<void> _lire() async {
    etat = EtatChargement.chargement;
    notifyListeners();
    try {
      _candidatures = await repository.toutes();
      etat =
          _candidatures.isEmpty ? EtatChargement.vide : EtatChargement.succes;
    } catch (_) {
      etat = EtatChargement.erreur;
    }
    notifyListeners();
  }

  Future<void> charger() async {
    if (_occupe) return;
    _occupe = true;
    try {
      await _lire();
    } finally {
      _occupe = false;
    }
  }

  Future<void> _modifier(Future<void> Function() operation) async {
    if (_occupe) throw StateError('Opération déjà en cours');
    _occupe = true;
    try {
      await operation();
      // Une lecture en échec se réessaie depuis l’accueil, sans rejouer l’écriture.
      await _lire();
    } catch (_) {
      etat = EtatChargement.erreur;
      notifyListeners();
      rethrow;
    } finally {
      _occupe = false;
    }
  }

  Future<void> enregistrer(Candidature candidature) =>
      _modifier(() => repository.enregistrer(candidature));
  Future<void> supprimer(Candidature candidature) =>
      _modifier(() => repository.supprimer(candidature.id!));
}
