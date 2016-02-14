# Development Environment

This repo contains the hermetic development environment for [redacted], hosted in a docker container image for
portability.

## Supported Operating Systems

### Mac OS X

El Capitan (10.11.3)

### Linux

#### Ubuntu
Trusty (14.04 LTS)

#### Mint
Rosa (17.3)

## Pre-requisites

#### Mac

install xcode command line tools: ```xcode-select --install```

## Setup

A one-time machine setup is required to prepare your machine to host running docker containers.

```wget -qO- https://raw.githubusercontent.com/chrisleck/personal/master/devenv/bootstrap.sh | bash```

## Usage

Once your machine has been set up and you are logged into docker hub with our docker credentials, you can kick off
the devenv container.
