#!/bin/bash
# $1: OpenCV4Tegra package name

# sudo dpkg --add-architecture armhf

while sudo fuser /var/lib/dpkg/lock > /dev/null 2>&1; do
    echo "Waiting for other apt-get command to finish"
    sleep 3
done

sudo dpkg -i ./$1
sudo apt-get update
sudo apt-get install -y --force-yes libopencv4tegra libopencv4tegra-dev
