Agnès Davière 10/09/2024
Structure du script pentes MNT

# ENTREE
-	Code postale  : caractères
-	Libelle commune : caractères
-	N° section : Liste ?
-	N° parcelle : Liste ?
  
# SORTIE
-	Fichier geopackage avec les couches suivantes :
  o	MNT (raster)
 	o	Cadastre non corrigé (vecteur)
 	o	Pentes catégorisées (raster)

# FONCTIONS INTERMEDIAIRES
## Etape 1 : travail sur une seule parcelle d’une seule commune. Ex : Parcelle 2594, section 0A à Salex. 
-	code_insee : OK
  o	Entrée : code postaux et libellés des communes (chaînes de caractères)
 	o	Sortie : code insee de la commune

-	get.cadastre : OK
  o	Entrée : code insee + n° de section + n° de parcelle
 	o	Sortie : limites cadastrales de la parcelle concernée, format vecteur

-	get.mnt :
  o	Entrée : couche cadastre format vecteur
 	o	Sortie : mnt format raster avec un buffer de 100m autour de la parcelle considérée
 	
-	pente :
  o	Entrée : mnt format raster et un vecteur de nombres représentant les catégories de pente
 	o	Sortie : raster de pentes catégorisées

-	geopackage :
  o	Entrée : liste de couches en format raster ou vecteur (possible de mélanger les 2 ?)
 	o	Sortie : un géopackage comprenant toutes les couches 

# FONCTIONS TEMPORAIRES EN DEHORS DU SCRIPT :
-	draw.vecteur (resp. draw.raster) :
  o	Entrée : couche format vecteur (resp. raster)
 	o	Sortie : plot dynamique de la couche
--> Pas dans le script final !


