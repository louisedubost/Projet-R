# Projet 5 - Récupération et traitement du MNT
# Récupérer le MNT de la zone d'étude avec happign et calculer les pentes
# Auteur : Agnès Davière (GF, AgroParisTech)
# Contact : agnes.daviere@agroparistech.fr
# Dernière mise à jour : 10 septembre 2024

# Libraries ----
librarian::shelf(happign,terra,tmap,sf)
tmap_mode("view")

# Set working directory ----
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Functions ----
code_post = "74420"
libelle <- "SAXEL"
section <- "0A"
num_parc <- "2594"

code.insee <- function(code_post, libelle){
  info_com <- get_apicarto_codes_postaux(code_post)
  ligne <- which(info_com$libelleAcheminement == libelle)
  code_insee <- info_com$codeCommune[[ligne]]
  return(code_insee)
}

code_insee <- code.insee(code_post, libelle)

get.cadastre <- function(code_insee, section, num_parc){
  zone_parca <- get_apicarto_cadastre(code_insee,
                                      type = "parcelle",
                                      code_com = NULL,
                                      section = section,
                                      numero = num_parc,
                                      dTolerance = 0L,
                                      source = "pci"
                                      )
  return(zone_parca)
}

zone_parca <- get.cadastre(code_insee, section, num_parc)

get.mnt <- function(zone_parca){
  mnt_layer_name <- "ELEVATION.ELEVATIONGRIDCOVERAGE"
  mnt <- get_wms_raster(x = zone_parca,
                        layer = mnt_layer_name, 
                        res = 10,
                        rgb = FALSE,
                        filename = "mnt.tif",
                        overwrite = TRUE
                        )
  return(mnt)
}

mnt <- get.mnt(zone_parca)  # rajouter un buffer de 100m autour des parcelles

slope <- function(mnt){
  classes <- c(0, 5, 15, 30, 45, 60, 90)
  pente <- terrain(mnt,
                   v = "slope",
                   unit = "degrees",
                   filename = "D:/Module R/projet5/pente.tif",
                   overwrite = TRUE
                   )
  pente_classee <- classify(pente, classes)
  return(pente_classee)
}

pente <- slope(mnt)

save.raster.gpkg <- function(SpatRaster) {
  layer_name <- names(SpatRaster)
  writeRaster(SpatRaster,
              filename = "pente.gpkg",
              filetype = "GPKG",
              gdal = c("APPEND_SUBDATASET=YES",
                       paste0("RASTER_TABLE=", layer_name))
  )
}

save.raster.gpkg(pente)

# save.vector.gpkg <- function(SpatVector) {
#   layer_name <- names(SpatVector)
#   st_write(SpatVector,
#            gpkg_path,
#            layer = "zone_parca",
#            append = TRUE
# 
# }
# 
# gpkg_path <- "C:/Users/Utilisateur/Documents/Projet-R/Script_R/MNT_pente/projet5.gpkg"
# save.vector.gpkg(zone_parca)


# Temporary functions ----
draw <- function(raster,vecteur){
  tm_shape(raster)+
    tm_raster()+
  tm_shape(vecteur)+
    tm_borders("black", lwd = 2)
}

representation <- draw(pente, zone_parca)
