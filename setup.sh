#!/bin/bash

# Arrêter les services
docker-compose down

# Supprimer les conteneurs
echo "#   Suppression des conteneurs"
NAME_DOCKER=(
    ["POSTGRESQL"]="postgresql"
    ["MSPR_KAWA_KEYCLOAK"]="mspr-kawa-keycloak"
    ["MSPR_KAWA_CLIENTS"]="mspr-kawa-clients"
    ["MSPR_KAWA_ORDERS"]="mspr-kawa-orders"
    ["MSPR_KAWA_PRODUCTS"]="mspr-kawa-products"
    ["MSPR_KAWA_DB"]="mspr-kawa-db"
)
for name in "${!NAME_DOCKER[@]}"; do
    (docker-compose rm -s "${NAME_DOCKER[$name]}" &)
done

wait

# Chemin vers le répertoire contenant les sous-dossiers avec les scripts
BASE_DIR="../"

# Liste des sous-dossiers et des scripts à exécuter
declare -A SCRIPTS
SCRIPTS=(
#    ["MSPR_KAWA_NGINX"]="dockerBuildRun.sh"
    ["MSPR_KAWA_KEYCLOAK"]="dockerBuildRun.sh"
    ["MSPR_KAWA_CLIENTS"]="dockerBuildRun.sh"
#    ["MSPR_KAWA_ORDERS"]="dockerBuildRun.sh"
#    ["MSPR_KAWA_PRODUCTS"]="dockerBuildRun.sh"
    ["MSPR_KAWA_DB_MAIN"]="dockerBuildRun.sh"
)

# Fonction pour exécuter un script dans un sous-dossier
execute_script() {
    local subfolder="$1"
    local script="$2"
    local script_path="$BASE_DIR$subfolder/$script"

    if [ -f "$script_path" ]; then
        (cd "$BASE_DIR/$subfolder" && "./$script")
    else
        echo "Erreur: $script_path n'est pas exécutable ou n'existe pas."
    fi
}

# Boucle sur la liste des sous-dossiers et scripts et exécution de chacun
for subfolder in "${!SCRIPTS[@]}"; do
    execute_script "$subfolder" "${SCRIPTS[$subfolder]}" &
done

wait

echo "#   All images of services are build"

echo "#   Lancement des conteneurs"
docker-compose up -d