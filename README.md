# Moteur multimodal (Processing)

Projet réalisé par **Bastien LALANNE** et **Marc GUEDON** dans le câdre de la 3ème année d'école d'ingénieur en Systèmes Robotiques et Intéractifs à l'UPSSITECH.

## Installation

Pour faire fonctionner notre moteur multimodal, il faut seulement installer [Java Runtime Environement 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html). \
**ATTENTION**: le moteur multimodal n'a été testé que sous Windows.

## Utilisation

Pour lancer notre moteur multimodal, il suffit simplement d'exécuter la commande suivante dans le dossier courant. Les applications Palette, SRA5 et OneDollarIvy seront alors exécutées. Il est également possible d'exécuter le Visionneur en ajoutant l'option `--visionneur` ou son diminutif `-v`.
```console
.\launcher.bat
.\launcher.bat -v
.\launcher.bat --visionneur
```

## Grammaire

DESSINER = {dessiner, créer, tracer} \
SUPPRIMER = {supprimer, effacer} \
DEPLACER = {déplacer,  bouger} \
QUITTER = {quitter, sortir, arrêter} \
ACTION = DESSINER | SUPPRIMER | DEPLACER \
FORME = {losange, rectangle, cercle, triangle} \
COULEUR = {rouge, orange, jaune, vert, bleu, violet, noir}

## Actions réalisables
### Ajout d'une forme

- Appuyer respectivement sur la touche "c", "r", "t" ou "l" pour ajouter un cercle, un rectangle, un triangle ou un losange gris où se trouve le pointeur. Si le pointeur se trouve en dehors de la fenêtre, la forme s'affiche au dernier endroit où était le pointeur dans la fenêtre.
- Prononcer "Dessiner + FORME + COULEUR" pour ajouter un objet ayant la forme et la couleur prononcée.
- Prononcer "Dessiner + FORME" pour ajouter un objet ayant la forme prononcée.
- Dessiner la forme souhaitée sur la fenêtre de OneDollarIvy, puis prononcer "Dessiner cette forme ici", pour ajouter un objet ayant la forme prononcée où se trouve le pointer.

### Déplacement d'une forme

- Appuyer sur "m"
- Cliquer sur l'objet à déplacer, puis prononcer "Déplacer cette forme ici", puis cliquer à l'endroit où déplacer la forme présélectionner.

### Suppression de formes

- Appuyer sur la touche "d" puis cliquer sur la forme voulue pour supprimer la forme en question.
- Prononcer "Supprimer + FORME + COULEUR" pour supprimer l'ensemble des objets ayant la forme et la couleur prononcées.
- Prononcer "Supprimer + FORME" pour supprimer l'ensemble des objets ayant la forme prononcée.
- Prononcer "Supprimer + COULEUR" pour supprimer l'ensemble des objets ayant la couleur prononcée.

### Quitter l'application

- Prononcer "QUITTER" pour quitter la palette.