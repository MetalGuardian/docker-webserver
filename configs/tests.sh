#!/bin/bash

set -e

export DISPLAY=:99

Xvfb :99 -shmem -screen 0 1366x768x16 &

fluxbox -display :99 &

x11vnc -passwd secret -display :99 -N -forever &

java -jar ./selenium-server-standalone.jar &
