# Chargement des packages
library(sf)
library(osmdata)
library(tmap)
library(happign)
library(readxl)
library(leaflet)

### Fonctions ----

# Définir la fonction pour afficher les clés OSM dans une fenêtre interactive
explore_osm_keys <- function() {
  
  # Étape 1: Récupérer les clés disponibles dans OSM et les stocker dans un data frame
  keys <- available_features()
  
  # Créer un data frame pour les clés
  keys_df <- data.frame(Key = keys)
  
  # Afficher les premières lignes du data frame pour vérifier
  print(head(keys_df))
  
  # Étape 2: Ouvrir les données dans une fenêtre interactive de RStudio
  View(keys_df)
  
  # Retourner le data frame au cas où l'utilisateur souhaite l'utiliser
  return(keys_df)
}

# Définir la fonction qui récupère les valeurs OSM possibles pour une clé spécifique
get_osm_values <- function(osm_key) {
  
  # Vérifier si la clé existe dans OSM
  keys_available <- available_features()
  if (!(osm_key %in% keys_available)) {
    stop(paste("La clé", osm_key, "n'existe pas dans OpenStreetMap. Veuillez vérifier la clé."))
  }
  
  # Étape 1: Récupérer les valeurs possibles pour la clé spécifiée
  values <- available_tags(osm_key)
  
  # Vérifier si des valeurs ont été trouvées pour cette clé
  if (length(values) == 0) {
    stop(paste("Aucune valeur trouvée pour la clé:", osm_key))
  }
  
  # Étape 2: Créer un data frame pour les valeurs
  values_df <- data.frame(Value = values)
  
  # Afficher les premières lignes du data frame pour vérification
  View(head(values_df))
  
  # Étape 3: Retourner le data frame
  return(values_df)
}

# Fonction pour créer une carte avec les données OSM basées sur une zone d'étude
create_osm_map <- function(zone_etude, osm_key, osm_value = "*") {
  # Convertir zone_etude en bbox
  bbox <- st_bbox(zone_etude)
  bbox_vector <- c(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"])
  
  # Définir la requête OSM
  opq_bbox <- opq(bbox = bbox_vector) %>%
    add_osm_feature(key = osm_key, value = osm_value)
  
  # Exécuter la requête et obtenir les données
  cway_zone <- osmdata_sf(opq_bbox)
  
  # Vérifier si les lignes OSM sont déjà au format sf
  if (!is.null(cway_zone$osm_lines)) {
    if (!inherits(cway_zone$osm_lines, "sf")) {
      cway_zone$osm_lines <- st_as_sf(cway_zone$osm_lines)
    }
  } else {
    message("Aucune donnée OSM pour les lignes n'a été trouvée.")
  }
  
  # Créer la carte
  map <- leaflet() %>%
    addTiles() %>%  # Fond de carte par défaut
    addPolylines(data = cway_zone$osm_lines, color = "blue", weight = 3, opacity = 0.7) %>%
    setView(lng = mean(bbox_vector[c(1, 3)]), lat = mean(bbox_vector[c(2, 4)]), zoom = 13)
  
  # Afficher la carte
  return(map)
}

### Script ----

## Importation des données cadastrales de la zone d'étude ----
# Créer un vecteur de nombres de 300 à 400
#nombres <- 1700:1760

# Convertir les nombres en chaînes de caractères avec formatage à 4 chiffres
# vecteur_chaine <- sprintf("%04d", nombres)

# Interroger une parcelle spécifique
Nancy_parca_pci <- get_apicarto_cadastre(
  x = "52023",               # Code INSEE en tant que chaîne
  type = "parcelle",         # Type de données : parcelle
  code_com = NULL,           # Optionnel
  #section = "0A",            # Section (vérifie si "OA" est correct pour cette commune)   # Numéros de parcelle (en boucle si nécessaire)
  source = "PCI",            # Source des données
)

# Visualiser les résultats (si la requête fonctionne)
qtm(Nancy_parca_pci)

zone_etude <- Nancy_parca_pci

## Appeler la fonction pour explorer les clés OSM

explore_osm_keys()
get_osm_values("route")

#Spécifier la clé et la valeur OSM
osm_key <- "route"   # Par exemple "highway" pour les routes
osm_value <- "foot"       # Par exemple "*" pour toutes les routes (ou un type spécifique comme "residential")
create_osm_map(zone_etude, osm_key, osm_value)



# réparation fonction ----

explore_osm_keys()
get_osm_values("highway")

osm_key_inuatilisables <- "forestry"
osm_key <- "highway"
osm_value <- "cycleway"

# Convertir zone_etude en bbox
bbox <- st_bbox(zone_etude)
bbox_vector <- c(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"])

# Définir la requête OSM
opq_bbox <- opq(bbox = bbox_vector) %>%
  add_osm_feature(key = osm_key, value = osm_value)

# Exécuter la requête et obtenir les données
cway_zone <- osmdata_sf(opq_bbox)

# Vérifier si les lignes OSM sont déjà au format sf
if (!is.null(cway_zone$osm_lines)) {
  # Vérifier si cway_zone$osm_lines est déjà au format sf, sinon le convertir
  if (!inherits(cway_zone$osm_lines, "sf")) {
    cway_zone$osm_lines <- st_as_sf(cway_zone$osm_lines)
  }
} else {
  # Si aucune donnée OSM n'est trouvée, créer une géométrie vide par défaut
  cway_zone$osm_lines <- st_sf(geometry = st_sfc())  # Géométrie vide
  message("Aucune donnée OSM pour les lignes n'a été trouvée. Une géométrie vide a été créée.")
}

# Créer la carte
map <- leaflet() %>%
  addTiles() %>%  # Fond de carte par défaut
  addPolylines(data = cway_zone$osm_lines, color = "blue", weight = 3, opacity = 0.7) %>%
  setView(lng = mean(bbox_vector[c(1, 3)]), lat = mean(bbox_vector[c(2, 4)]), zoom = 13)

# Afficher la carte
return(map)

<<<<<<< HEAD

### Fonction pour obtenir toutes les clés et valeurs avec des données non NULL dans la zone d'étude ----
get_osm_keys_values <- function(zone_etude) {
  
  # Convertir la zone d'étude en bbox
  bbox <- st_bbox(zone_etude)
  bbox_vector <- c(bbox["xmin"], bbox["ymin"], bbox["xmax"], bbox["ymax"])
  
  # Récupérer toutes les clés disponibles dans OSM
  all_keys <- available_features()
  
  # Liste pour stocker les résultats
  keys_values_with_data <- list()
  
  # Liste pour stocker les clés problématiques
  problematic_keys <- list()
  
  # Boucle à travers toutes les clés
  for (osm_key in all_keys) {
    
    # Essayer de récupérer les valeurs possibles pour cette clé
    possible_values <- tryCatch({
      available_tags(osm_key)
    }, error = function(e) {
      # Si la clé est invalide ou pose un problème, ajouter à la liste des clés problématiques et passer à la suivante
      message(paste("Clé problématique rencontrée :", osm_key, " - Erreur :", e$message))
      problematic_keys[[length(problematic_keys) + 1]] <- osm_key
      return(NULL)
    })
    
    # Si possible_values est NULL, passer à la prochaine clé
    if (is.null(possible_values)) next
    
    # Boucler à travers les valeurs possibles pour cette clé
    for (osm_value in possible_values) {
      
      # Créer une requête OSM pour la clé et la valeur
      opq_query <- opq(bbox = bbox_vector) %>%
        add_osm_feature(key = osm_key, value = osm_value)
      
      # Télécharger les données OSM sous forme de sf
      osm_data <- tryCatch({
        osmdata_sf(opq_query)
      }, error = function(e) {
        # Si un problème survient lors de la récupération des données, ignorer cette combinaison clé/valeur
        message(paste("Erreur lors de la récupération des données pour la clé :", osm_key, "et la valeur :", osm_value))
        next
      })
      
      # Vérifier si des données OSM non NULL sont présentes
      if (!is.null(osm_data$osm_points) || !is.null(osm_data$osm_lines) || !is.null(osm_data$osm_polygons)) {
        
        # Ajouter la clé et la valeur dans la liste des résultats s'il y a des données
        if (is.null(keys_values_with_data[[osm_key]])) {
          keys_values_with_data[[osm_key]] <- list()
        }
        keys_values_with_data[[osm_key]] <- append(keys_values_with_data[[osm_key]], osm_value)
      }
    }
  }
  
  # Créer un rapport final sur les clés problématiques
  message("Clés problématiques rencontrées :", paste(problematic_keys, collapse = ", "))
  
  # Retourner les clés/valeurs avec des données disponibles et les clés problématiques
  return(list("data" = keys_values_with_data, "problematic_keys" = problematic_keys))
}

  
# Appeler la fonction pour obtenir toutes les clés et valeurs avec des données disponibles
osm_keys_values <- get_osm_keys_values(zone_etude)

# Afficher les résultats
print(osm_keys_values)

# Afficher les résultats
View(osm_keys_values$keys_values_with_data)  # Clés et valeurs avec des données
View(osm_keys_values$problematic_keys)
=======
getwd()
>>>>>>> aa3d3ac01eab8f3fe9b27961b8b465417f5cec1a
