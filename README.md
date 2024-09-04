# Projet-R-Desserte forestière
Projet R desserte
1-	Trouver les données publiques sur la desserte, étudier les tables attributaires des shapes (données de l’IGN ou données OpenStreetMaps (package R existant)
2-	Travail sur la définition de l’accessibilité et donc créer des indices
3-	Déterminer des données d’entrées de la fonction : routes accessibles grumiers et routes accessibles skiddeur/porteur (données issues de OpenStreetMpas, IGN ou vectorisé sur ArcGis)
4-	Déterminer avec une fonction R les distances accessibles au porteur et au skkideur de part et d’autre de la route forestière
5-	Prendre en compte le MNT et calculer la pente avec le package terra de happign
6-	Créer une fonction qui fait des buffers de part de d’autres de la desserte en prennant en compte la pente
7-	En sortie : faire un raster et créer des indices d’exploitabilité (surface accessible /surface de forêt)
