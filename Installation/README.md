# Installation Procedure

To install Gadgetron, it has traditionally been necessary to compile the source code. And while this is still an option (see below), we do reccomend that you take a look at the precompiled packages available through the Gradient Software PPA. This makes the Gadgetron software suite available on Ubuntu with very little hazzle.   

## Ubuntu

To install Gadgetron using the Gradient Software PPA, first add the PPA to your software sources: 
```bash 
sudo add-apt-repository ppa:gradient-software/experimental
sudo apt-get update
```

Installing Gadgetron is then merely a matter of requesting it from your package manager:
```bash
sudo apt-get install gadgetron-all
```

If you plan to use the Python modules included with Gadgetron, please install the Python Gadgetron interface as well: 
```bash
pip3 install --user gadgetron
```

*Note: I'm still working on the PPA, so it might not be working just yet. -KLK*

## Windows

While Gadgetron does compile natively on Windows, no binary package is available. We recommend that you in stead use WSL, and use the Ubuntu packages as described above.  

Microsoft has provided excellent documentation for [installing WSL](https://docs.microsoft.com/en-us/windows/wsl/about). 

Install Ubuntu 18.04 or 20.04, and follow the instructions above to complete your Gadgetron installation.

## Mac OS 

Gadgetron doesn't currently build on Mac OS. You best option is probably to run Gadgetron in a docker container. 

*Note: Stay tuned for more detailed instructions.*

## Installing from Source Code

Compiling Gadgetron from sources is the traditional method of installation. It should be reasonably easy on most Linux distributions. You can find detailed instructions [here](https://github.com/gadgetron/gadgetron/wiki/Linux-Installation-(Gadgetron-4)). 

## Potential issue

### add-apt-repository: command not found

Fresh Ubutnu installations might not come with the `add-apt-repository` command installed. It's part of the `software-properties-common` package, and can simply be installed: 
```bash
sudo apt-get install software-properties-common
```
