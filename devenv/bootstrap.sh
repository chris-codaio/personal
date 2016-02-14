#!/bin/bash

# This bootstrap script sets up the minimal software required to get our development environment
# docker container up and running.
#
# It should work on MacOS X and x86-based Debian-compatible Linux distros

set -eo pipefail

if [[ -z "$TERM" ]]; then
  txtdef=''
  txtund=''
  txtbld=''
  bldgrn=''
  bldred=''
  bldblu=''
  bldyel=''
  bldwht=''
  txtrst=''
else
  # Text color variables
  txtdef=$(tput sgr0)
  txtund=$(tput sgr 0 1)          # Underline
  txtbld=$(tput bold)             # Bold
  bldred=${txtbld}$(tput setaf 1 || true) #  red - ignore failures on non-capable terminals
  bldgrn=${txtbld}$(tput setaf 2 || true) #  green - ignore failures on non-capable terminals
  bldyel=${txtbld}$(tput setaf 3 || true) #  yellow - ignore failures on non-capable terminals
  bldblu=${txtbld}$(tput setaf 4 || true) #  blue - ignore failures on non-capable terminals
  bldwht=${txtbld}$(tput setaf 7 || true) #  white - ignore failures on non-capable terminals
  txtrst=$(tput sgr0)             # Reset
fi

# usage: log([warn|error|info], message)
function log() {
  local txttag
  case $1 in
    info)  txttag=${bldwht};   shift 1 ;;
    warn)  txttag=${bldyel};   shift 1 ;;
    error) txttag=${bldred};   shift 1 ;;
    pass)  txttag=${bldblu};   shift 1 ;;
    *)     txttag=${txtdef};           ;;
  esac
  echo "${txttag}$(date +'%Y-%m-%dT%H:%M:%S%z') ${@}${txtdef}"
}

if [[ $(uname) == 'Linux' ]] && which apt-get > /dev/null; then
  log info "Updating package repos..."
  sudo apt-add-repository -y ppa:git-core/ppa
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

  if lsb_release -s -d | grep -q Ubuntu; then
    DISTRO="Ubuntu"
    RELEASE=$(lsb_release -s -c)
  elif lsb_release -s -d | grep -q Debian; then
    DISTRO="Debian"
    RELEASE=$(lsb_release -s -c)
  elif lsb_release -s -d | grep -q Mint; then
    DISTRO="Ubuntu"
    RELEASE=$(lsb_release -u -s -c)
  else
    log warn "Unknown Debian-derivative, assuming Debian sources work"
    DISTRO="Debian"
    RELEASE=$(lsb_release -s -c)
  fi
  sudo add-apt-repository -y "deb http://apt.dockerproject.org/repo ${DISTRO,,}-${RELEASE} main"
  
  sudo apt-get -q update
  log pass "Package repos updated"

  log info "Installing pre-reqs..."
  sudo apt-get install -qfuy apt-transport-https ca-certificates
  log pass "Pre-reqs installed"

  log info "Installing latest GIT..."
  sudo apt-get install -qfuy git
  log pass "GIT installed"

  log info "Installing docker pre-reqs..."
  sudo apt-get purge -qfuy lxc-docker
  sudo apt-get install -qfuy cgroup-lite lxc
  sudo apt-get install -qfuy linux-image-extra-$(uname -r) apparmor
  log pass "Docker pre-reqs installed"

  log info "Installing docker..."
  sudo apt-get install -qfuy docker-engine

  if [[ -z "$(groups | grep docker)" ]]; then
    log info "Adding user to docker group..."
    sudo usermod -aG docker $USER
    log pass "User added to group"

    log warn "After your next logout/login cycle, docker should work without requiring sudo access."
    log warn "Until then, you'll need to use sudo to access docker."
  fi

  log info "Setting up docker hub credentials - you'll need to check 1password or ask around for the shared password."
  sudo docker login --username krypton --email docker-admins@krypton.io
  log pass "Docker hub access set up"

elif [[ $(uname) == 'Darwin' ]]; then
  OSX_VERSION=$(sw_vers -productVersion)
  if [[ "$OSX_VERSION" != "10.11.3" ]]; then
    log warn "You are running an untested version of Mac OS X"
  fi

  if [[ -z $(which brew) ]]; then
    log info "Installing homebrew package manager...may require sudo permissions"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    log pass "Homebrew installed"
  fi

  if [[ -d "/usr/local" ]]; then
    OWNER=$(stat -f "%Su" /usr/local)
    if [[ "$OWNER" -ne "$USER" ]]; then
      log info "Applying El Capitan fix for /usr/local access..."
      sudo chown -R $(whoami):admin /usr/local
      log pass "/usr/local fixed"
    fi
  fi

  log info "Updating homebrew..."
  brew update
  log pass "Homebrew update complete"

  log info "Upgrading installed homebrew packages"
  brew upgrade
  log pass "Homebrew packages updated."

  log info "Installing latest GIT..."
  brew install git
  log pass "GIT installed"

  log info "Installing docker pre-reqs..."
  brew install dlite
  log pass "Docker pre-reqs installed"

  log info "Installing docker..."
  brew install docker
  log pass "Docker installed"

  log info "Setting up docker hub credentials - you'll need to check 1password or ask around for the shared password."
  docker login --username krypton --email docker-admins@krypton.io
  log pass "Docker hub access set up"
fi

log pass "Bootstrap complete. Try running '[sudo] docker run -it --rm hello-world' to test your docker environment"
