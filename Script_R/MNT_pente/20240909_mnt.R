# Projet 5 - Récupération et traitement du MNT
# Récupérer le MNT de la zone d'étude avec happign et calculer les pentes
# Auteur : Agnès Davière (GF, AgroParisTech)
# Contact : agnes.daviere@agroparistech.fr
# Dernière mise à jour : 09 septembre 2024

# Libraries ----
library(happign)
library(ggplot2)
library(terra)
library(tmap)
library(sf)
tmap_mode("view")

# Set working directory ----
setwd("D:/Module R/projet5")

# Mes fonctions ----
## créer une fonction qui enregistre mes couches en geopackage

# ----
# Récupération du MNT de la zone d'étude à partir de l'IGN
## Importation du cadastre de la zone d'étude COMPARER PCI et BDP!!!???

cod_post = "74420"
com <- get_apicarto_codes_postaux(cod_post)

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
gpkg_path <- "D:/Module R/projet5/projet5.gpkg"
st_write(zone_parca,
         gpkg_path,
         layer = "zone_parca",
         append = TRUE
)

## Importation du MNT de la zone d'étude
layers <- get_layers_metadata("wms-r", "altimetrie" )
mnt_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE"

mnt <- get_wms_raster(x = zone_parca,
                      layer = mnt_layer_name, 
                      res = 10,
                      rgb = FALSE,
                      filename = "D:/Module R/projet5/mnt.tif",  # automatiser le chemin d'accès
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
