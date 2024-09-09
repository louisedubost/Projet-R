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


# Exportation geopackage ----

st_write(routes, 
         "desserte.gpkg", 
         layer = "routes", 
         driver = "GPKG")

st_write(troncon_hydro, 
         "desserte.gpkg", 
         layer = "troncon_hydro", 
         driver = "GPKG")

st_write(parca_real_clean, 
         "desserte.gpkg", 
         layer = "Saxel_parca_pci_2154"
         driver = "GPKG")





