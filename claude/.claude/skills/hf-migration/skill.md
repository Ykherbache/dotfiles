---
name: hf-migration
description: Convertit un texte décrivant des défis (HF) One Piece RPG (style Discord) en fichier SQL de migration prêt à l'emploi. Écrit le fichier dans src/migrations/ automatiquement.
---

# Skill : hf-migration

Ce skill convertit du texte libre décrivant des défis (Hauts Faits / HF) en un fichier SQL de migration prêt à exécuter, suivant exactement le format du projet onepiece-rpg-v2.

## Table cible : `hf`

```sql
CREATE TABLE `hf` (
    `id`              bigint(20) NOT NULL AUTO_INCREMENT,
    `titre`           text       NOT NULL,
    `description`     text       NOT NULL,
    `type`            text       NOT NULL,  -- '' ou 'unique'
    `maxi`            bigint(20) NOT NULL,  -- objectif max à atteindre
    `points`          bigint(20) NOT NULL,  -- points HF récompensés
    `type_recompense` text       NOT NULL,  -- 'personnage' ou 'titre'
    `recompense`      text       NOT NULL,  -- nom_raccourci du perso OU nom du titre
)
```

## Flux d'exécution

1. **Lire tout le texte** fourni avant de faire quoi que ce soit
2. **Lister les défis détectés** avec leurs champs parsés — confirmer avec l'utilisateur
3. **Regrouper les questions** : demander en une seule question tous les champs ambigus (type, maxi, points, type_recompense)
4. **Générer le SQL complet** une fois tout résolu
5. **Proposer un nom de fichier** `YYYY_MM_description.sql` et demander confirmation
6. **Écrire le fichier** dans `src/migrations/` via l'outil Write
7. **Confirmer** le chemin et rappeler : exécuter via PhpMyAdmin port 3200 ou `docker exec`

## Règles de parsing

### titre
Le nom court et lisible du défi. Conserver tel quel depuis l'input.

### description
La description complète du défi. Conserver telle quelle.
- Apostrophes → doubler : `l'arène` → `l''arène`
- Utiliser des **double guillemets** comme délimiteur de string pour les descriptions (comme dans le fichier de référence) afin d'éviter les conflits avec les apostrophes fréquentes.
- **Encodage latin1 OBLIGATOIRE** : la table `hf` est en `latin1`. Tous les caractères accentués doivent être encodés en latin1 mal-interprété en UTF-8. Table de correspondance :
  - `à` → `Ã ` (Ã + espace)
  - `é` → `Ã©`
  - `è` → `Ã¨`
  - `ê` → `Ãª`
  - `â` → `Ã¢`
  - `ô` → `Ã´`
  - `û` → `Ã»`
  - `î` → `Ã®`
  - `ç` → `Ã§`
  - `ù` → `Ã¹`
  - `É` → `Ã‰`
  - `è` → `Ã¨`
  - `ó` → `Ã³`
  - `ú` → `Ãº`
  Appliquer ce même encodage au `titre` et à la `recompense` si ils contiennent des accents.

### type
- `'unique'` — défi à faire une seule fois (one-shot, obtention d'un personnage, quête narrative)
- `''` (vide) — défi répétable/cumulatif (victoires, kills, montée de niveaux, etc.)

**Règle heuristique :**
- Si `maxi = 1` → probablement `'unique'`
- Si `maxi > 1` → probablement `''`
- Toujours confirmer si ambigu

### maxi
Le nombre cible à atteindre. Extraire depuis l'input (ex: "vaincre 5 fois" → `5`, "obtenir l'accès" → `1`).

### points
Points HF attribués. Valeurs standards observées :
- `10` — défi normal
- `15` — défi difficile ou important (boss, titre)

Si non précisé dans l'input, demander ou utiliser `10` par défaut avec un `-- TODO: verify points`.

### type_recompense
- `'personnage'` — récompense = déblocage d'un personnage jouable
- `'titre'` — récompense = titre cosmétique

### recompense
- Si `type_recompense = 'personnage'` → utiliser le `nom_raccourci` exact du personnage (lowercase, espaces→`_`, accents supprimés). Ex: `'don_chinjao'`, `'gold_roger_legacy'`, `'shirahoshi'`
- Si `type_recompense = 'titre'` → le nom du titre tel quel. Ex: `'Héros de Dressrosa'`, `'Grade 4'`

## Format de sortie SQL

Reproduire **exactement** le style de `src/migrations/2026_05_dressrosa_hf.sql`.

### Structure du fichier

```sql
-- Date : YYYY-MM
-- Défis : Titre1, Titre2, ...

INSERT INTO `hf` (`titre`, `description`, `type`, `maxi`, `points`, `type_recompense`, `recompense`)
VALUES
('Titre du défi 1',  "Description du défi 1",  'unique', 1,  10, 'personnage', 'nom_raccourci'),
('Titre du défi 2',  "Description du défi 2",  '',       50, 10, 'personnage', 'nom_raccourci'),
('Titre du défi 3',  "Description du défi 3",  'unique', 1,  15, 'titre',      'Nom du Titre');
```

### Règles de ponctuation critiques
- `titre` et `recompense` → délimiteurs **simples** `'...'`
- `description` → délimiteurs **doubles** `"..."` (évite les conflits avec apostrophes)
- Apostrophes dans `titre` ou `recompense` → doubler : `l'arène` → `l''arène`
- Pas besoin d'échapper dans `description` grâce aux double guillemets
- Dernière ligne se termine par `;`, toutes les autres par `,`

### Alignement
Aligner les colonnes avec des espaces comme dans le fichier de référence.

## Valeurs types selon le contexte

| Contexte | type | maxi | points | type_recompense |
|---|---|---|---|---|
| Vaincre un boss une fois | `'unique'` | 1 | 10-15 | `'personnage'` |
| Avancer dans une quête | `'unique'` | 1 | 10 | `'personnage'` |
| Vaincre N fois | `''` | N | 10-15 | `'personnage'` ou `'titre'` |
| Atteindre un score/niveau | `''` | N | 10 | `'personnage'` |
| Remporter N victoires JcJ | `''` | N | 10-15 | `'personnage'` |
| Obtenir un titre cosmétique | `'unique'` ou `''` | N | 15 | `'titre'` |
| Donner N familiers colorés | `''` | N | 10-15 | `'personnage'` |

## Cas limites

| Situation | Comportement |
|---|---|
| Points non précisés | Utiliser `10` + `-- TODO: verify points` |
| type ambigu | Demander avant de générer |
| nom_raccourci perso inconnu | Utiliser le slug déduit + `-- TODO: verify recompense` |
| Plusieurs défis pour le même perso | Générer autant de lignes que nécessaire |
| Condition de déblocage dans le texte | Ignorer (géré ailleurs dans le code), ne pas mettre en SQL |

## Vérification avant écriture

1. Chaque ligne a bien les 7 colonnes dans l'ordre : `titre`, `description`, `type`, `maxi`, `points`, `type_recompense`, `recompense`
2. Le dernier `;` est bien placé (pas de virgule finale)
3. Les `nom_raccourci` dans `recompense` correspondent aux slugs existants ou nouvellement créés
