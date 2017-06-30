#!/bin/bash
# $1: cuda debian file name 
# $2: cuda_ver (example 6.0, 6.5)
# $3: cuda_dash_ver (6-0, 6-5)

if [ $# != 3 ] ; then
    echo "Incorrect arguments, use following command to install cuda"
    echo "$0 cuda_deb_file_name 6.5 6-5"
    exit 1
fi

while fuser /var/lib/dpkg/lock > /dev/null 2>&1; do
    echo "Waiting for other apt-get command to finish"
    sleep 3
done

#dima
# sudo dpkg --force-all -i ~/cuda-l4t/$1
# / dima
sed -i.bak 's/\(^deb.*main restricted\)\s*$/\1 universe multiverse/g' /etc/apt/sources.list
sed -i.bak 's/\(^deb.*main restricted universe\)\s*$/\1 multiverse/g' /etc/apt/sources.list

apt-get -y update
#  dima
apt-get -y install cuda-8-0
# / dima
apt-get -y --force-yes install cuda-toolkit-$3 libgomp1 libfreeimage-dev libopenmpi-dev openmpi-bin

grep -q "export PATH=.*/usr/local/cuda-$2/bin" ~/.bashrc || echo "export PATH=/usr/local/cuda-"$2"/bin:$PATH">>~/.bashrc

if dpkg --print-architecture | grep -q arm64; then 
    lib_dir=lib64
else
    lib_dir=lib
fi
grep -q "export LD_LIBRARY_PATH=/usr/local/cuda-$2/$lib_dir" ~/.bashrc || echo "export LD_LIBRARY_PATH=/usr/local/cuda-"$2"/"$lib_dir":$LD_LIBRARY_PATH" >> ~/.bashrc
export LD_LIBRARY_PATH=/usr/local/cuda-$2/$lib_dir:$LD_LIBRARY_PATH
 
