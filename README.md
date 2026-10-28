# Extension Quarto : diapositives HE-Arc Ingénierie (Beamer et reveal.js)

Extension Quarto pour produire des présentations de cours en PDF (Beamer) et en HTML
(reveal.js), avec un thème graphique aligné sur le logo HE-Arc Ingénierie (rouge `#FF0000`,
noir, fond blanc).

Elle fournit trois formats :

| Format                       | Fichier produit          | Usage                                         |
|------------------------------|--------------------------|-----------------------------------------------|
| `theme-hearc-beamer`         | `cours.pdf`              | projection, avec animations (pauses, listes progressives) |
| `theme-hearc-beamer+handout` | `cours-handout.pdf`      | à distribuer, sans animations : une page par diapositive, dans son état final |
| `theme-hearc-revealjs`       | `cours.html`             | projection dans un navigateur, avec notes de l'orateur (touche `S`) |

## Prérequis

- [Quarto](https://quarto.org) ≥ 1.4
- Une distribution LaTeX avec `xelatex` (MiKTeX, TeX Live ou `quarto install tinytex`),
  pour les formats PDF uniquement

## Installation

Dans le dépôt du cours :

```sh
quarto add fabrizioalbertetti/quarto_theme_hearc/extension
```

L'extension est installée dans `_extensions/fabrizioalbertetti/theme-hearc/` (à committer avec le
cours). Utiliser ensuite le format dans `_quarto.yml` ou dans l'en-tête d'un `.qmd` :

```yaml
format: theme-hearc-beamer
```

Pour partir de l'exemple complet, copier aussi les fichiers de départ (`_quarto.yml` et
`01-exemple.qmd`) :

```sh
quarto use template fabrizioalbertetti/quarto_theme_hearc/example
```

### Fichiers à ignorer

Au rendu, l'extension copie le thème et le logo à côté de chaque `.qmd`. Ajouter au `.gitignore`
du dépôt (Quarto ne copie pas les fichiers cachés d'un template) :

```gitignore
beamerthemehearc-ing.sty
logo-he-arc-ing.jpg
_output/
/.quarto/
```

### Mise à jour

```sh
quarto update extension fabrizioalbertetti/quarto_theme_hearc/extension
```

Pour figer une version, ajouter un tag : `quarto add fabrizioalbertetti/quarto_theme_hearc/extension@v1.0.0`.

## Utilisation

1. Adapter les **paramètres communs** dans `_quarto.yml` :

   ```yaml
   course:
     name: "Intelligence Artificielle"
     short: "IA"        # pied de page (optionnel)
     class: "ISC3"     # classe / volée
     footer: ""          # texte à gauche du pied de page (optionnel)
   author: "Fabrizio Albertetti"
   institute: "HE-Arc Ingénierie"

   format:
     theme-hearc-beamer:
       theme: hearc-ing # ou Madrid, Boadilla, metropolis, ...
     theme-hearc-beamer+handout: default   # optionnel : version à distribuer
     theme-hearc-revealjs: default         # optionnel : version HTML
   ```

   Les options données sous un format ne s'appliquent qu'à lui : en cas de changement
   (par ex. `theme:`), les reporter sous les deux formats Beamer. Pour reveal.js, `theme:`
   attend un fichier `.scss` ou un thème reveal.js standard.

2. Créer une présentation par fichier `.qmd`, avec ses **paramètres propres** :

   ```markdown
   ---
   title: "Héritage et polymorphisme"
   subtitle: "Semaine 3"
   ---

   # Section

   ## Titre de la diapositive

   - contenu
   ```

3. Générer les présentations :

   ```sh
   quarto render                   # toutes les présentations, tous les formats → _output/
   quarto render 03-heritage.qmd   # une seule
   quarto render 03-heritage.qmd --to theme-hearc-beamer+handout   # un seul format
   quarto preview 03-heritage.qmd  # rendu automatique à chaque sauvegarde
   ```

Toute clé définie dans un `.qmd` remplace celle de `_quarto.yml` (par ex. `date`, `author`).

## Syntaxe utile

| Élément               | Syntaxe                                         |
|-----------------------|-------------------------------------------------|
| Page de section       | `# Titre`                                       |
| Diapositive           | `## Titre`                                      |
| Bloc / alerte / exemple | `### Titre`, `### Titre {.alert}`, `### Titre {.example}` |
| Pause                 | `. . .`                                         |
| Liste progressive     | `::: incremental` … `:::`                       |
| Colonnes              | `:::: columns` + `::: {.column width="50%"}`    |
| Contenu trop long     | `## Titre {.allowframebreaks}` (PDF : plusieurs pages ; HTML : défilement) |
| Notes de l'orateur    | `::: notes` … `:::` (reveal.js uniquement, jamais dans les PDF) |
| Contenu propre à un format | `::: {.content-visible when-format="beamer"}` (ou `"revealjs"`) |
| Image pour les deux formats | `![](images/schema)` sans extension : `schema.pdf` en Beamer, `schema.svg` en reveal.js |

Le LaTeX brut (`\only<2>{…}`, blocs ```` ```{=latex} ````) est ignoré par reveal.js : réserver
les animations Beamer à un bloc `when-format="beamer"` et prévoir leur équivalent reveal.js
(fragments). Voir [example/01-exemple.qmd](example/01-exemple.qmd) pour un exemple complet,
commenté.

## Structure du dépôt

```
extension/                   l'extension Quarto (installée par `quarto add`)
  _extensions/theme-hearc/
    _extension.yml           formats `theme-hearc-beamer`, `+handout` et `theme-hearc-revealjs`
    beamerthemehearc-ing.sty thème Beamer (couleurs, titre, pied de page)
    hearc-ing.scss           thème reveal.js, même charte
    title-slide.html         page de titre reveal.js (cours, classe, logo)
    course-meta.lua          transmet `course.*` au thème ; en reveal.js, pied de page et blocs `###`
    handout-rename.lua       renomme `cours+handout.pdf` en `cours-handout.pdf` après le rendu
    handout-last-slide.tex   handout : ne garde que la dernière étape des animations de chaque diapositive
    logo-he-arc-ing.jpg      logo de la page de titre
example/                     projet Quarto d'exemple qui utilise l'extension
  _quarto.yml                paramètres communs du cours
  01-exemple.qmd             présentation d'exemple
  images/                    images en .pdf (Beamer) et .svg (reveal.js)
    src/                     sources TikZ ; `sh images/src/build.sh` régénère les images
```

## Développement

L'exemple utilise une copie locale de l'extension (`example/_extensions/`, ignorée par git).
Après chaque modification dans `extension/`, la réinstaller puis regénérer l'exemple :

```sh
cd example
quarto add ../extension --no-prompt
quarto render                   # → example/_output/01-exemple.pdf
```

## Personnalisation

- **Couleurs, polices, mise en page** : `extension/_extensions/theme-hearc/beamerthemehearc-ing.sty`
  (PDF) et `hearc-ing.scss` (reveal.js) ; à modifier ensemble pour garder les deux formats alignés.
  Pour une modification propre à un cours, éditer la copie installée dans ce cours ;
  pour la partager, la faire dans ce dépôt puis `quarto update` dans les cours.
- **Police** : la police sans-serif par défaut (Latin Modern Sans) fonctionne partout ;
  pour une police plus proche de la charte, ajouter par ex. `sansfont: Arial` sous
  `format: theme-hearc-beamer:` (police à installer sur la machine).
- **Autre thème Beamer** : `theme: Madrid` (et éventuellement `colortheme:`). Le nom du
  cours et la classe ne sont alors plus affichés (ils dépendent du thème `hearc-ing`).
