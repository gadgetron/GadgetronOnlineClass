# Installation procedure

This document should first summarize how to install MRD and Gadgetron depending of the OS.

Follow by a precise description of the procedure or a link to a procedure 




## Windows

# Using WSL (install Ubuntu with Microsoft Store) :

sudo apt-get update --quiet 
sudo apt-get install --no-install-recommends --no-install-suggests --yes software-properties-common apt-utils wget build-essential cython3 python3-dev python3-pip libhdf5-serial-dev cmake git-core libboost-all-dev libfftw3-dev h5utils jq hdf5-tools liblapack-dev libatlas-base-dev libxml2-dev libfreetype6-dev pkg-config libxslt-dev libarmadillo-dev libace-dev gcc-multilib libgtest-dev liblapacke-dev libplplot-dev libdcmtk-dev supervisor supervisor net-tools cpio libpugixml-dev jove libopenblas-base libopenblas-dev libpugixml-dev

pip3 install -U pip setuptools
pip3 install numpy scipy Cython tk-tools matplotlib scikit-image opencv_python pydicom scikit-learn sympy

sudo apt-get install --no-install-recommends --no-install-suggests --yes python3-psutil python3-pyxb python3-lxml python3-pil python3-h5py
DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends --no-install-suggests --yes python3-tk

pip3 install torch==1.4.0+cpu torchvision==0.5.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# for embedded python plot, we need agg backend
sudo mkdir -p /root/.config/matplotlib && sudo touch /root/.config/matplotlib/matplotlibrc 

# not sure if this is appropriate, but rights need to be changed here
sudo chmod -R 777 /root/.config/matplotlib/ 
sudo echo "backend : agg" >> /root/.config/matplotlib/matplotlibrc

# Set more environment variables in preparation for Gadgetron installation
export GADGETRON_HOME=/usr/local
export ISMRMRD_HOME=/usr/local
export PATH=$PATH:$GADGETRON_HOME/bin:$ISMRMRD_HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ISMRMRD_HOME/lib:$GADGETRON_HOME/lib

export GADGETRON_URL=https://github.com/gadgetron/gadgetron
export GADGETRON_BRANCH=master

sudo mkdir /opt/code
# same, rights need to be changed here
cd /opt/code 
sudo chmod -R 777 /opt/code
git clone https://github.com/ismrmrd/ismrmrd.git

cd ismrmrd
mkdir build 
cd build 
cmake ../ 
make -j $(nproc) 
sudo make install
cd /opt/code 

git clone ${GADGETRON_URL} --branch ${GADGETRON_BRANCH} --single-branch 
cd gadgetron 
mkdir build 
cd build 
cmake ../ 
make -j $(nproc) 
sudo make install 

/opt/code/gadgetron/docker/manifest --key .io.gadgetron.gadgetron.sha1 --value `git rev-parse HEAD` 

cp /opt/code/gadgetron/docker/start_supervisor /opt/ 
cp /opt/code/gadgetron/docker/supervisord.conf /opt/

# Install Python interface.
pip3 install gadgetron

# HASH for ISMRMRD
cd /opt/code/ismrmrd 
/opt/code/gadgetron/docker/manifest --key .io.gadgetron.ismrmrd.sha1 --value `git rev-parse HEAD` 

# SIEMENS_TO_ISMRMRD
cd /opt/code 
git clone https://github.com/ismrmrd/siemens_to_ismrmrd.git
cd siemens_to_ismrmrd 
mkdir build 
cd build 
cmake ../ 
make -j $(nproc) 
sudo make install 
/opt/code/gadgetron/docker/manifest --key .io.gadgetron.siemens_to_ismrmrd.sha1 --value `git rev-parse HEAD`


# !! optional !!, need to remake gadgetron

sudo apt-get install freeglut3-dev
sudo apt-get install libglew-dev

# ZFP
cd /opt
git clone https://github.com/hansenms/ZFP.git
cd ZFP 

mkdir lib 
make 
make shared 
sudo make -j $(nproc) install

# BART
export BART_URL=https://github.com/mrirecon/bart
export BART_BRANCH=master

sudo apt-get install --no-install-recommends --no-install-suggests --yes liblapacke-dev
cd /opt/code 
git clone ${BART_URL} --branch ${BART_BRANCH} --single-branch 
cd bart 
make -j $(nproc) 
sudo make install


# CERES
sudo apt-get install --yes libgoogle-glog-dev libeigen3-dev libsuitesparse-dev
cd /opt/code 
wget http://ceres-solver.org/ceres-solver-1.14.0.tar.gz 
tar zxf ceres-solver-1.14.0.tar.gz 
mkdir ceres-bin 
cd ceres-bin 
cmake ../ceres-solver-1.14.0 
make -j$(nproc)
sudo make install

# ? Clean up packages.
# sudo apt-get clean
# sudo rm -rf /var/lib/apt/lists/*


## Linux

docker (pros and cons)
warning docker with matlab 
warning docker with GPU
or 
from source

## Mac OS 

No chance

## Potential issue

Common issues could be also indicated 

