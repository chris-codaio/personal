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

  echo "Installing pre-reqs..."
  sudo apt-get install -qfuy apt-transport-https ca-certificates

  echo "Installing GIT 2.7.1..."
  sudo apt-get install -qfuy git

  echo "Installing docker pre-reqs..."
  sudo apt-get install -qfuy cgroup-lite lxc

  echo "Installing docker..."
  sudo apt-get purge -qfuy lxc-docker
  sudo apt-get install -qfuy linux-image-extra-$(uname -r) apparmor
  sudo apt-get install -qfuy docker-engine

  echo "Starting docker..."
  sudo service docker start

elif onMacOs; then
  echo "Installing homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo "Installing docker pre-reqs..."
  brew install dlite

  echo "Installing docker..."
  brew install docker
fi
