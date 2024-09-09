# Projet 5 - Récupération et traitement du MNT
# Récupérer le MNT de la zone d'étude avec happign et calculer les pentes
# Auteur : Agnès Davière (GF, AgroParisTech)
# Contact : agnes.daviere@agroparistech.fr
# Dernière mise à jour : 09 septembre 2024

# Libraries ----
library(happign)
library(terra)
library(tmap)
library(sf)
tmap_mode("view")

# Set working directory ----
setwd("C:/Users/Utilisateur/Documents/Projet-R/Script_R/MNT_pente")

# Mes fonctions ----
## créer une fonction qui enregistre mes couches en geopackage

# ----
# Récupération du MNT de la zone d'étude à partir de l'IGN
## Importation du cadastre de la zone d'étude COMPARER PCI et BDP!!!???

cod_post = "74420"
libelle <- "SAXEL"

info_com <- get_apicarto_codes_postaux(cod_post)
ligne_saxel <- which(info_com$libelleAcheminement == libelle)
code_insee2 <- info_com[info_com$nomCommune == "nom_com", "codeCommune"]


cod_insee <- "74261" # a récupérer de manière automatique depuis com
num_parc <- "2594"
section <- "0A"
zone_parca <- get_apicarto_cadastre(cod_insee,
                                    type = "parcelle",
                                    code_com = NULL,
                                    section = section, #section de parcelle, vérifié sur géoportail
                                    numero = num_parc,
                                    dTolerance = 0L,
                                    source = "pci",
)

tm_shape(zone_parca)+
  tm_polygons()

## Enregistrement du parcellaire en format .gpkg
gpkg_path <- "C:/Users/Utilisateur/Documents/Projet-R/Script_R/MNT_pente/projet5.gpkg"
st_write(zone_parca,
         gpkg_path,
         layer = "zone_parca",
         append = TRUE
)

## Importation du MNT de la zone d'étude
#buffer_zone_parca <- st_buffer(zone_parca, dist = 100)
#bbox <- st_bbox(buffer_zone_parca) #récupérer les coordonnées de la zone buffer
layers <- get_layers_metadata("wms-r", "altimetrie" )
mnt_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE"

mnt <- get_wms_raster(x = zone_parca,
                      layer = mnt_layer_name, 
                      res = 10,
                      rgb = FALSE,
                      filename = "C:/Users/Utilisateur/Documents/Projet-R/Script_R/MNT_pente//mnt.tif",  # automatiser le chemin d'accès
                      overwrite = TRUE
                      )
# essayer d'ajouter le mnt au gpkg ainsi qu'un buffer de 100m autour de la parcelle

tm_shape(mnt)+
  tm_raster()+
tm_shape(zone_parca)+
  tm_borders("black", lwd = 2)

# Calcul de la pente ----

pente <- terrain(mnt,
                 v = "slope",
                 unit = "degrees",
                 filename = "D:/Module R/projet5/pente.tif",
                 overwrite = TRUE
                 )

classes <- c(0, 5, 15, 30, 45, 60, 90)
classes_pente <- classify(pente, classes)
plot(classes_pente)

tm_shape(classes_pente)+
  tm_raster()+
tm_shape(zone_parca)+
  tm_borders("black", lwd = 2)
