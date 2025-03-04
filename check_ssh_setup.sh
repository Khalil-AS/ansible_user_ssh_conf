#!/bin/bash

## Auteur : Khalil
## Date : 04/03/2025
## Version : rev 1

## Objectif :
# Ce script vérifie la configuration SSH et sudo pour un utilisateur sur un système AlmaLinux

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Journalisation
LOGFILE="verify_ssh_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Fonction pour afficher un message de succès
success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

# Fonction pour afficher un message d'avertissement
warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

# Fonction pour afficher un message d'erreur et quitter
fail() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
    exit 1
}

# Variables
SSH_USER="control"
SSH_KEY_TYPE="ed25519"
SSH_KEY_PATH="/home/${SSH_USER}/.ssh/id_${SSH_KEY_TYPE}"
ANSIBLE_GROUP="preprod"  # Remplace par ton groupe Ansible

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN} Vérification de la configuration SSH & Sudo ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""

# Vérifier l'existence de la clé SSH sur le nœud de contrôle
echo -e "${YELLOW}Étape 1 : Vérification de la clé SSH...${NC}"
if ansible localhost -m stat -a "path=${SSH_KEY_PATH}.pub" | grep -q '"exists": true'; then
    success "La clé SSH existe sur le nœud de contrôle."
else
    fail "La clé SSH est absente sur le nœud de contrôle."
fi
echo ""

# Vérifier la présence de l'utilisateur sur les nœuds distants
echo -e "${YELLOW}Étape 2 : Vérification de l'utilisateur SSH...${NC}"
if ansible $ANSIBLE_GROUP -m command -a "id ${SSH_USER}" | grep -q "uid="; then
    success "L'utilisateur ${SSH_USER} existe sur les nœuds distants."
else
    fail "L'utilisateur ${SSH_USER} n'existe pas sur les nœuds distants."
fi
echo ""

# Vérifier si la clé publique est dans authorized_keys
echo -e "${YELLOW}Étape 3 : Vérification de la clé publique dans authorized_keys...${NC}"
if ansible $ANSIBLE_GROUP -m shell -a "grep -q 'ed25519 ' /home/${SSH_USER}/.ssh/authorized_keys" 2>/dev/null; then
    success "La clé publique est bien présente dans authorized_keys."
else
    fail "La clé publique est absente de authorized_keys."
fi
echo ""

# Vérifier la présence de l'entrée sudoers
echo -e "${YELLOW}Étape 4 : Vérification des droits sudo...${NC}"
if ansible $ANSIBLE_GROUP -b -m command -a "grep '^${SSH_USER} ALL=(ALL) NOPASSWD:ALL' /etc/sudoers" > /dev/null 2>&1; then
    success "L'utilisateur ${SSH_USER} a bien les permissions sudo."
else
    fail "L'utilisateur ${SSH_USER} n'a pas les permissions sudo."
fi
echo ""

# Vérifier les permissions du dossier .ssh
echo -e "${YELLOW}Étape 5 : Vérification des permissions du dossier .ssh...${NC}"
if ansible $ANSIBLE_GROUP -m stat -a "path=/home/${SSH_USER}/.ssh" | grep -q '"mode": "0700"'; then
    success "Les permissions du dossier .ssh sont correctes."
else
    warning "Les permissions du dossier .ssh ne sont pas 0700."
fi
echo ""

# Vérifier les permissions du fichier authorized_keys
echo -e "${YELLOW}Étape 6 : Vérification des permissions de authorized_keys...${NC}"
if ansible $ANSIBLE_GROUP -m stat -a "path=/home/${SSH_USER}/.ssh/authorized_keys" | grep -q '"mode": "0600"'; then
    success "Les permissions de authorized_keys sont correctes."
else
    warning "Les permissions de authorized_keys ne sont pas 0600."
fi
echo ""

echo -e "${GREEN}✅ Vérification terminée !${NC}"
