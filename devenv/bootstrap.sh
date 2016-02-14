#!/bin/bash

# This bootstrap script sets up the minimal software required to get our development environment
# docker container up and running.
#
# It should work on MacOS X and x86-based Debian-compatible Linux distros

set -eo pipefail

function onLinux() {
  if [[ $(uname) == 'Linux' ]] && which apt-get > /dev/null; then
    return 0
  fi

  return 1
}

function onMacOs() {
  if [[ $(uname) == 'Darwin' ]]; then
    return 0
  fi

  return 1
}

if onLinux; then
  echo "Updating package repos..."
  sudo apt-add-repository ppa:git-core/ppa
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
  sudo add-apt-repository "deb http://apt.dockerproject.org/repo ${DISTRO,,}-${RELEASE} main"
  
  sudo apt-get update

  echo "Installing pre-reqs..."
  sudo apt-get install apt-transport-https ca-certificates

  echo "Installing GIT 2.7.1..."
  sudo apt-get install git

  echo "Installing docker pre-reqs..."
  sudo apt-get install cgroup-lite lxc

  echo "Installing docker..."
  sudo apt-get purge lxc-docker
  sudo apt-get install linux-image-extra-$(uname -r) apparmor
  sudo apt-get install docker-engine

  echo "Starting docker..."
  sudo service docker start

elif onMacOs; then
  # Install homebrew
  # Install dlite
  # Install docker
fi
