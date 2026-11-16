import 'widgets/statut_badge.dart';
import 'package:flutter/material.dart';
import '../models/candidature.dart';
import '../state/candidature_controller.dart';

class CandidatureFormPage extends StatefulWidget {
  const CandidatureFormPage(
      {super.key, required this.controller, this.initiale});
  final CandidatureController controller;
  final Candidature? initiale;

  @override
  State<CandidatureFormPage> createState() => _CandidatureFormPageState();
}

class _CandidatureFormPageState extends State<CandidatureFormPage> {
  final _form = GlobalKey<FormState>();
  late final _poste = TextEditingController(text: widget.initiale?.poste);
  late final _entreprise =
      TextEditingController(text: widget.initiale?.nomEntreprise);
  late final _url = TextEditingController(text: widget.initiale?.url);
  late final _notes = TextEditingController(text: widget.initiale?.notes);
  late Statut _statut = widget.initiale?.statut ?? Statut.brouillon;
  late DateTime? _relance = widget.initiale?.relance;
  bool _enCours = false;

  @override
  void dispose() {
    _poste.dispose();
    _entreprise.dispose();
    _url.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final choix = await showDatePicker(
        context: context,
        initialDate: _relance ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2200));
    if (mounted && choix != null) setState(() => _relance = choix);
  }

  Future<void> _enregistrer() async {
    if (_enCours || !_form.currentState!.validate()) return;
    setState(() => _enCours = true);
    final maintenant = DateTime.now();
    final candidature = Candidature(
      id: widget.initiale?.id,
      poste: _poste.text.trim(),
      nomEntreprise: _entreprise.text.trim(),
      statut: _statut,
      relance: _relance,
      url: _url.text.trim(),
      notes: _notes.text.trim(),
      dateCreation: widget.initiale?.dateCreation ?? maintenant,
      dateModification: maintenant,
    );
    try {
      await widget.controller.enregistrer(candidature);
      if (mounted) Navigator.pop(context, candidature);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enCours = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Échec de l’enregistrement. Réessaie.')));
    }
  }

  String? _obligatoire(String? valeur) =>
      valeur == null || valeur.trim().isEmpty ? 'Champ obligatoire' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.initiale == null
              ? 'Nouvelle candidature'
              : 'Modifier la candidature')),
      body: Form(
          key: _form,
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Le poste et l’entreprise',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Ces deux informations sont obligatoires.',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const SizedBox(height: 24),
                    TextFormField(
                        controller: _poste,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Poste',
                            prefixIcon: Icon(Icons.work_outline)),
                        validator: _obligatoire),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _entreprise,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: 'Entreprise',
                            prefixIcon: Icon(Icons.business_outlined)),
                        validator: _obligatoire),
                    const SizedBox(height: 20),
                    const SizedBox(height: 8),
                    Text('Suivi de la candidature',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<Statut>(
                      value: _statut,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: [
                        for (final statut in Statut.values)
                          DropdownMenuItem(
                              value: statut, child: Text(statut.libelle))
                      ],
                      onChanged: (valeur) {
                        if (valeur != null) setState(() => _statut = valeur);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        tileColor: Theme.of(context).colorScheme.surface,
                        leading: const Icon(Icons.event_outlined),
                        title: const Text('Date de relance'),
                        subtitle: Text(_relance == null
                            ? 'Choisir une date'
                            : MaterialLocalizations.of(context)
                                .formatShortDate(_relance!)),
                        onTap: _choisirDate,
                        trailing: _relance == null
                            ? null
                            : IconButton(
                                tooltip: 'Effacer la date',
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _relance = null))),
                    const SizedBox(height: 28),
                    Text('Informations complémentaires',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _url,
                        keyboardType: TextInputType.url,
                        decoration: const InputDecoration(
                            labelText: 'URL (facultatif)')),
                    const SizedBox(height: 20),
                    TextFormField(
                        minLines: 3,
                        maxLines: 6,
                        controller: _notes,
                        decoration: const InputDecoration(
                            labelText: 'Notes (facultatif)')),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _enCours ? null : _enregistrer,
                        child:
                            Text(_enCours ? 'Enregistrement…' : 'Enregistrer')),
                  ]))),
    );
  }
}
