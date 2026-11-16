enum Statut { brouillon, envoyee, entretien, offre, refusee }

class Candidature {
  Candidature({
    this.id,
    required this.nomEntreprise,
    required this.poste,
    required this.statut,
    DateTime? dateCreation,
    DateTime? dateModification,
    this.relance,
    this.url = '',
    this.notes = '',
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateModification = dateModification ?? dateCreation ?? DateTime.now();

  final int? id;
  final String nomEntreprise;
  final String poste;
  final Statut statut;
  final DateTime dateCreation;
  final DateTime dateModification;
  final DateTime? relance;
  final String url;
  final String notes;
}
