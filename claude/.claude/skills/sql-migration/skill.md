---
name: sql-migration
description: Convertit un texte décrivant des personnages One Piece RPG (style Discord) en fichier SQL de migration prêt à l'emploi. Écrit le fichier dans src/migrations/ automatiquement.
---

# Skill : sql-migration

Ce skill convertit du texte libre (messages Discord de game designers) décrivant des personnages et leurs attaques en un fichier SQL de migration prêt à exécuter, suivant exactement le format du projet onepiece-rpg-v2.

## Tables cibles

**`persos`** : `nom_perso`, `nom_raccourci`, `classe_perso`

**`attaques`** : `id` (toujours NULL), `nom`, `perso`, `niveau`, `degats`, `degats_base`, `pp`, `pp_base`, `effet`, `commentaire`

La colonne `perso` dans `attaques` doit correspondre exactement au `nom_raccourci` du personnage dans `persos`.

## Flux d'exécution

Quand le skill est invoqué, suivre CET ordre précis :

1. **Lire tout le texte** fourni avant de faire quoi que ce soit
2. **Lister les personnages détectés** avec le nombre d'attaques trouvées par personnage — confirmer avec l'utilisateur
3. **Regrouper les questions** : demander `classe_perso` en une seule question pour tous les cas ambigus, et les `effet` ambigus en une seule question. Ne jamais poser plusieurs questions séparées.
4. **Générer le SQL complet** une fois tout résolu
5. **Proposer un nom de fichier** `YYYY_MM_description.sql` et demander confirmation
6. **Écrire le fichier** dans `src/migrations/` via l'outil Write
7. **Confirmer** le chemin absolu et rappeler : exécuter via PhpMyAdmin sur le port 3200 ou `docker exec`

## Règles de parsing

### nom_perso
Conserver le nom complet tel quel, y compris les qualificatifs entre parenthèses comme `(Modèle "Legacy")`, `(Gear Fourth)`, etc. sauf `(ROBOT)` qui est purement technique.

Exemples :
- `Gold Roger (Modèle "Legacy") (ROBOT)` → `nom_perso` = `Gold Roger (Modèle "Legacy")`
- `Luffy Gear Fourth` → `nom_perso` = `Luffy Gear Fourth`

### nom_raccourci
Lowercase, espaces et tirets → `_`, accents supprimés, caractères spéciaux retirés. Intégrer le qualificatif distinctif pour éviter les collisions.

Exemples :
- `Gold Roger (Modèle "Legacy")` → `gold_roger_legacy`
- `Luffy Gear Fourth` → `luffy_gear_fourth`
- `Luffy Gear Fifth` → `luffy_gear_fifth`
- `Don Chinjao` → `don_chinjao`
- `Lao G` → `lao_g`
- `Dorry` → `dorry`

### classe_perso
Inférer depuis le contexte si possible, sinon demander. Valeurs connues :
- `'Equipage de Luffy'`
- `'Personnages déblocables'`
- `'Ile de Dressrosa'` (disponibles directement sur l'île)
- `'Ile de Punk Hazard'`, `'Ile de Sabaody'`, etc. (adapter le nom d'île)
- `'Equipage de Baggy'`, `'Equipage de Shanks'`, `'Equipage de Barbe Blanche'`, `'Equipage de Barbe Noire'`

Par défaut si incertain : `'Personnages déblocables'` avec un `-- TODO: verify classe_perso`.

### Parsing d'une attaque
Chercher le pattern : `Niv N : TypeAttaque` suivi de `NomAttaque : Description`

Exemples de formats acceptés :
```
Niv 0 : Attaque de base (2 Force)
Pistolame : Le robot effectue une entaille rapide...

Niv 0 Attaque de base
Gomu Gomu no Léo Bazooka: Rétracte ses deux poings...

Niv 0 : Attaque de base
Ikoku : crée une lame d'air avec son épée.
```

Extraire : `niveau` (le N), `effet` (via lookup ci-dessous), `nom` (avant le `:`), `commentaire` (après le `:`).

## Lookup : texte → effet

| Texte dans l'input | effet SQL |
|---|---|
| Attaque de base / basique / simple | `attaque` |
| Attaque Combo / combo | `attaque_combo` |
| Recul / Attaque recul / attaque_recul | `attaque_recul` |
| Contre / Contre-attaque / Contrer / Évite et frappe | `evite_et_frappe` |
| Paralysie / Paralyse / immobilise | `paralyse` |
| Soin / Récupération / Soigne / Heal | `soigne` |
| Boost / Augmente attaque / augmente_attaque | `augmente_attaque` |
| Esquive / Dodge | `esquive` |
| Renvoi / Réflexion / Renvoie | `renvoi` |
| Attaque puissante (niv 65) | `attaque` |
| ATTAQUE ULTRA / Ultra / attaque_ultra | `attaque_ultra` |

Si ambigu, noter avec `-- TODO: verify effet` et demander à l'utilisateur.

## Lookup : degats et pp par niveau/effet

| niveau | effet | degats | degats_base | pp | pp_base |
|---|---|---|---|---|---|
| 0 | attaque | 5 | 5 | 2 | 2 |
| 15 | attaque_combo | 8 | 8 | 5 | 5 |
| 15 | attaque_recul | 25 | 25 | 13 | 13 |
| 22 | evite_et_frappe | 19 | 19 | 18 | 18 |
| 35 | augmente_attaque | 0 | 0 | 11 | 11 |
| 35 | soigne | 36 | 36 | 21 | 21 |
| 45 | soigne | 36 | 36 | 21 | 21 |
| 45 | augmente_attaque | 0 | 0 | 11 | 11 |
| 50 | esquive | 0 | 0 | 6 | 6 |
| 60 | renvoi | 0 | 0 | 5 | 5 |
| 65 | attaque | 21 | 21 | 10 | 10 |
| 65 | paralyse | 0 | 0 | 6 | 6 |
| 75 | attaque_ultra | 25 | 25 | 13 | 13 |
| 75 | paralyse | 0 | 0 | 6 | 6 |
| 75 | attaque_recul | 25 | 25 | 13 | 13 |

**Règle générale :** `degats_base = degats` et `pp_base = pp` toujours.

Si la combinaison niveau/effet n'est pas dans le tableau : utiliser `0, 0, 0, 0` et ajouter `-- TODO: check degats/pp`.

## Format de sortie SQL

Reproduire **exactement** le style de `src/migrations/2026_05_dressrosa_persos.sql`.

### Structure du fichier

```sql
-- Date : YYYY-MM
-- Personnages : Nom1, Nom2, Nom3

-- ============================================================
-- 1. PERSOS
-- ============================================================

-- Dispos directement sur l'île  (si classe = 'Ile de ...')
INSERT INTO `persos` (`nom_perso`, `nom_raccourci`, `classe_perso`)
VALUES ('Nom', 'slug', 'Ile de ...');

-- Personnages à débloquer  (si classe = 'Personnages déblocables')
INSERT INTO `persos` (`nom_perso`, `nom_raccourci`, `classe_perso`)
VALUES ('Nom1', 'slug1', 'Personnages déblocables'),
       ('Nom2', 'slug2', 'Personnages déblocables');

-- ============================================================
-- 2. ATTAQUES
-- Format : (NULL, nom, perso, niveau, degats, degats_base, pp, pp_base, effet, commentaire)
-- ============================================================

INSERT INTO `attaques` (`id`, `nom`, `perso`, `niveau`, `degats`, `degats_base`, `pp`, `pp_base`, `effet`, `commentaire`)
VALUES

-- --------------------------------------------------------
-- NOM PERSONNAGE EN MAJUSCULES
-- --------------------------------------------------------
(NULL, 'Attaque1', 'slug', 0,  5,  5,  2,  2,  'attaque',          'Description.'),
(NULL, 'Attaque2', 'slug', 15, 8,  8,  5,  5,  'attaque_combo',    'Description.'),
(NULL, 'Attaque3', 'slug', 22, 19, 19, 18, 18, 'evite_et_frappe',  'Description.'),
(NULL, 'Attaque4', 'slug', 35, 0,  0,  11, 11, 'augmente_attaque', 'Description.'),
(NULL, 'Attaque5', 'slug', 45, 36, 36, 21, 21, 'soigne',           'Description.'),
(NULL, 'Attaque6', 'slug', 50, 0,  0,  6,  6,  'esquive',          'Description.'),
(NULL, 'Attaque7', 'slug', 60, 0,  0,  5,  5,  'renvoi',           'Description.'),
(NULL, 'Attaque8', 'slug', 65, 21, 21, 10, 10, 'attaque',          'Description.'),

-- --------------------------------------------------------
-- NOM PERSONNAGE 2 EN MAJUSCULES
-- --------------------------------------------------------
(NULL, 'Attaque1', 'slug2', 0,  5,  5,  2,  2,  'attaque',         'Description.'),
...
(NULL, 'DerniereAttaque', 'slug2', 75, 25, 25, 13, 13, 'attaque_ultra', 'Description.');
```

### Règles de ponctuation critiques
- Toutes les lignes VALUES se terminent par `,` **sauf** la toute dernière qui se termine par `;`
- Apostrophes dans les textes → doubler : `l'ennemi` → `l''ennemi`
- Double guillemets dans `nom_perso` : pas d'échappement (ex: `'Gold Roger (Modèle "Legacy")'` est correct)

### Alignement des colonnes
Aligner verticalement `niveau`, `degats`, `pp`, `effet` avec des espaces. Voir le fichier de référence `2026_05_dressrosa_persos.sql` pour le style exact. Les valeurs à 1 chiffre utilisent un espace supplémentaire (ex: `0,  5,  5,  2,  2,`).

## Encodage latin1 OBLIGATOIRE

Les tables `persos` et `attaques` sont en `latin1`. Tous les caractères accentués dans `nom_perso`, `classe_perso` et `commentaire` doivent être encodés en latin1 interprété comme UTF-8. Table de correspondance :

| Caractère | Encodage |
|---|---|
| à | `Ã ` (Ã + espace) |
| é | `Ã©` |
| è | `Ã¨` |
| ê | `Ãª` |
| â | `Ã¢` |
| ô | `Ã´` |
| û | `Ã»` |
| î | `Ã®` |
| ç | `Ã§` |
| ù | `Ã¹` |
| É | `Ã‰` |
| È | `Ãˆ` |
| Ê | `ÃŠ` |
| œ | `Å"` |

## Cas limites

| Situation | Comportement |
|---|---|
| Niveau manquant dans l'input | Émettre `-- TODO: missing niveau X` à l'emplacement attendu |
| Combo niveau/effet inconnu | Valeurs `0, 0, 0, 0` + `-- TODO: check degats/pp` |
| Description vide | `''` + `-- TODO: add description` |
| `(ROBOT)` dans le header | Ignorer pour `nom_perso`, inclure un qualificatif dans `nom_raccourci` si nécessaire |
| Personnage avec variante (Gear 4, Legacy...) | Intégrer la variante dans le slug pour éviter collision |
| Attaque "Attaque puissante" au niv 65 | effet = `attaque`, degats = 21, pp = 10 |
| Soigne au niv 35 au lieu de boost | Accepter, utiliser degats=36, pp=21 |

## Vérification avant écriture

Avant de générer le SQL final :
1. Vérifier que chaque `nom_raccourci` est unique dans l'output
2. S'assurer que les 9 niveaux standard sont couverts (0, 15, 22, 35, 45, 50, 60, 65, 75) ou mettre des TODO
3. Vérifier que le dernier `;` est bien placé (pas de virgule finale)
