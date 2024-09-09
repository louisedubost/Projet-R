------------------------------------------------------------------------
  
title: "Test script R -projet"
author: "Killian BAUE"
Contact: "killian.baue@agroparistech.fr"
format: R

```         
df-print: paged
self-contained: true
```

editor: visual

------------------------------------------------------------------------

# chargement des library ----


library(readxl)
library(happign)
library(tmap)
library(sf)
library(dplyr)  
tmap_mode("view")


# Importation des données cadastrales de la zone d'étude ----


# Créer un vecteur de nombres de 300 à 400
nombres <- 1500:1600

# Convertir les nombres en chaînes de caractères avec formatage à 4 chiffres
vecteur_chaine <- sprintf("%04d", nombres)


# Interroger une parcelle spécifique
Saxel_parca_pci <- get_apicarto_cadastre(
  x = "74261",               # Code INSEE en tant que chaîne
  type = "parcelle",         # Type de données : parcelle
  code_com = NULL,           # Optionnel
  section = "0A",            # Section (vérifie si "OA" est correct pour cette commune)
  numero = vecteur_chaine,   # Numéros de parcelle (en boucle si nécessaire)
  code_arr = NULL,           # Optionnel
  code_abs = NULL,           # Optionnel
  dTolerance = 0L,           # Tolérance
  source = "pci",            # Source des données
  progress = TRUE            # Afficher la progression
)

# Visualiser les résultats (si la requête fonctionne)
qtm(Saxel_parca_pci)


Saxel_parca_pci_2154 <- st_transform(Saxel_parca_pci,
                                      2154)

st_write(Saxel_parca_pci_2154,
         "testRprojet.gpkg",
         layer = "Saxel_parca_pci_2154",
         append = TRUE)

st_layers("Saxel_parca_pci_2154")

ortho_layers <- get_layers_metadata("wms-r","ortho")

IRC_layer_name <- "ORTHOIMAGERY.ORTHOPHOTOS.IRC"

IRC <- get_wms_raster(x = Saxel_parca_pci,
                      layer = IRC_layer_name, 
                      res = 10)

tm_shape(IRC)+
  tm_rgb()+
  tm_shape(Saxel_parca_pci)+
  tm_borders(col = 'white')




altimetrie_layers <- get_layers_metadata("wms-r","altimetrie")

MNT_layer_name <- "RGEALTI-MNT_PYR-ZIP_FXX_LAMB93_WMS"
MNS_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE.HIGHRES.MNS"

MNT <- get_wms_raster(x = Saxel_parca_pci,
                      layer = MNT_layer_name, 
                      res = 10,
                      rgb = FALSE)

MNS <- get_wms_raster(x = Saxel_parca_pci,
                      layer = MNS_layer_name, 
                      res = 10,
                      rgb = FALSE)


MNH <- MNS - MNT
MNH[MNH < 0] <- 0


# Passer en mode interactif
tmap_mode("view")


qtm(MNH)+
  tm_raster()+
  tm_shape(Saxel_parca_pci)+
  tm_borders(col = 'white')


# chargements des vecteurs : réseaux routier et hydrographique ----

topographie_layers <- get_layers_metadata("wfs","topographie")

routes <- get_wfs(Saxel_parca_pci,
                  "BDTOPO_V3:troncon_de_route",
                  spatial_filter = "intersects")

troncon_hydro <-get_wfs(Saxel_parca_pci,
                        "BDTOPO_V3:troncon_hydrographique",
                        spatial_filter = "intersects")

tm_shape(Saxel_parca_pci) +
  tm_borders() +  # Ajouter les frontières de la parcelle
  tm_shape(routes) +
  tm_lines(col = "red", lwd = 1, legend.col.title = "Routes") +  # Routes en rouge
  tm_shape(troncon_hydro) +
  tm_lines(col = "blue", lwd = 1, legend.col.title = "Ruisseaux") +  # Ruisseaux en bleu
  tm_layout(legend.outside = TRUE)  # Afficher la légende en dehors de la carte


# buffer ----

# Assurez-vous que les routes sont bien un objet sf
routes <- st_as_sf(routes)  # Conversion des routes en 'sf' si ce n'est pas déjà le cas

# Créer des buffers linéaires autour des routes pour les différentes distances
buffer_20m <- st_buffer(routes, dist = 20)
buffer_40m <- st_buffer(routes, dist = 40)
buffer_60m <- st_buffer(routes, dist = 60)
buffer_80m <- st_buffer(routes, dist = 80)

# Vérification et correction de la validité des géométries
buffer_20m <- st_make_valid(buffer_20m)
buffer_40m <- st_make_valid(buffer_40m)
buffer_60m <- st_make_valid(buffer_60m)
buffer_80m <- st_make_valid(buffer_80m)

# Créer des buffers cumulés pour chaque catégorie
buffer_0_20m <- st_difference(buffer_20m, st_buffer(routes, dist = 0))
buffer_20_40m <- st_difference(buffer_40m, buffer_20m)
buffer_40_60m <- st_difference(buffer_60m, buffer_40m)
buffer_60_80m <- st_difference(buffer_80m, buffer_60m)

# Assurez-vous que les géométries sont valides après les opérations spatiales
buffer_0_20m <- st_make_valid(buffer_0_20m)
buffer_20_40m <- st_make_valid(buffer_20_40m)
buffer_40_60m <- st_make_valid(buffer_40_60m)
buffer_60_80m <- st_make_valid(buffer_60_80m)

# Convertir en objets sf avec une colonne 'Buffer' pour indiquer les distances
buffer_0_20m_sf <- st_sf(geometry = st_geometry(buffer_0_20m), Buffer = "0 à 20 m")
buffer_20_40m_sf <- st_sf(geometry = st_geometry(buffer_20_40m), Buffer = "20 à 40 m")
buffer_40_60m_sf <- st_sf(geometry = st_geometry(buffer_40_60m), Buffer = "40 à 60 m")
buffer_60_80m_sf <- st_sf(geometry = st_geometry(buffer_60_80m), Buffer = "60 à 80 m")

# Combiner les buffers en une seule couche
buffers_combined <- rbind(
  buffer_0_20m_sf,
  buffer_20_40m_sf,
  buffer_40_60m_sf,
  buffer_60_80m_sf
)

# S'assurer que toutes les géométries sont valides
buffers_combined <- st_make_valid(buffers_combined)

# Visualisation des buffers avec des nuances monochromes et transparentes
tm_shape(Saxel_parca_pci) +
  tm_borders() +  # Ajouter les frontières de la parcelle
  tm_shape(buffers_combined) +
  tm_fill(col = "Buffer", 
          palette = "-Blues",  # Palette monochrome dans des nuances de bleu
          alpha = 0.3,  # Transparence pour voir le parcellaire en dessous
          legend.col.title = "Distance") +
  tm_shape(routes) +
  tm_lines(col = "red", lwd = 2, legend.col.title = "Routes") +  # Routes en rouge
  tm_shape(troncon_hydro) +
  tm_lines(col = "blue", lwd = 2, legend.col.title = "Ruisseaux") +  # Ruisseaux en bleu
  tm_layout(legend.outside = TRUE, 
            legend.outside.position = "right",  # Légende en dehors de la carte
            legend.title.size = 1.2, 
            legend.text.size = 1)














# Exportation geopackage ----

st_write[routes,
         "pplmt_data_gpkg",
         layer = "routes"]

st_write[troncon_hydro,
         "pplmt_data_gpkg",
         layer = "troncon_hydro"]

st_write[parca_real_clean,
         "pplmt_data_gpkg",
         layer = "parca_real_clean"]




writeRaster(
  IRC,
  "pplt_data_gpkg",
  filetype = "GPKG",
  gdal = c("APEND_SUBDATASET=YES",
           "RASTER_table=IRC"))

writeRaster(
  MNH,
  "pplt_data_gpkg",
  filetype = "GPKG",
  gdal = c("APEND_SUBDATASET=YES",
           "RASTER_table=MNH"))
