# Utiliser une ancienne version de Python (ici Python 3.6)
FROM python:3.6-slim

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installer la version spécifique de Cutadapt (1.11)
RUN pip install cutadapt==1.11

# Créer un répertoire de travail
WORKDIR /data

# Définir la commande d'entrée par défaut pour le container
ENTRYPOINT ["cutadapt"]
