# Prerequisites
 
The Gadgetron Online Class features several exercises, as well as live demos during which you might wish to follow along at home. In planning the courses, we assume participants will already have the following:  
 
 - A working Gadgetron installation (see instructions below).
   - Including the Gadgetron Python interface.
   - Including the Gadgetron Matlab interface (if you are interested in using Matlab with Gadgetron).
 - A suite of scientific programming tools.
   - Python; matplotlib, numpy, scipy.
   - Matlab 2018b or newer; if interested. (For lower version see [instruction](https://github.com/gadgetron/GadgetronOnlineClass/blob/master/Courses/Day3/Lecture2/README.md#installation))
 - A basic familiarity with linux shell commands.  
 - A comfortable text editor (or IDE) for Python, XML, C++, etc.
   
# Installation Procedure
 
To install Gadgetron, it has traditionally been necessary to compile the source code. And while this is still an option (see below), we do recommend that you take a look at the precompiled packages available in the Gradient Software PPA. This makes the Gadgetron software suite available on Ubuntu through the package manager.    
 
## Ubuntu
 
To install Gadgetron using the Gradient Software PPA, first add the PPA to your software sources:  
```bash  
sudo add-apt-repository ppa:gradient-software/experimental && sudo apt-get update
```
 
Gadgetron (and related software) can then be installed using the package manager. The Gadgetron Python interface can be installed using `pip`:
```bash
sudo apt-get install gadgetron-all && pip3 install --user gadgetron
```
 
If you have Matlab, and intend to use it with Gadgetron, you should install the Gadgetron Matlab interface. This is done though the Matlab 'Add-Ons' interface - simply search for 'gadgetron' and install the toolbox. Matlab 2018a or newer is required.
 
## Windows
 
While Gadgetron does compile natively on Windows, no binary package is available. We recommend that you in stead use WSL, and use the Ubuntu packages as described above.   
 
Microsoft has provided excellent documentation for [installing WSL](https://docs.microsoft.com/en-us/windows/wsl/about).  
 
Install Ubuntu 18.04 or 20.04, and follow the instructions above to complete your Gadgetron installation.
 
## Mac OS  
 
Gadgetron doesn't currently build on Mac OS.  You may try MacPorts or HomeBrew.  However, users should have better luck with the following options:
 
- Software such as Parallels, VirtualBox, etc., can be used to install a Ubuntu virtual machine (VM), then install Gadgetron into that Ubuntu VM, as detailed above for the native Ubuntu installation.
 
- Alternatively, Docker Desktop Community Edition for Mac can be used to download and install a Gadgetron Docker container.  After the Docker software installation is complete, and a network connection is available, the Gadgetron Docker container is installed by running the command:
 
```
docker pull gadgetron/ubuntu_2004
```
 
Once the container has been downloaded and installed into the user's Docker environment, the user should then be able to launch it as they would any other container, for example:
 
```
docker run --name gtLocal gadgetron/ubuntu_2004
```
 
and interact with the running container using any of Docker's standard suite of command line tools.
 
## Installing from Source Code
 
Compiling Gadgetron from sources is the traditional method of installation. It should be reasonably easy on most Linux distributions. You can find detailed instructions [here](https://github.com/gadgetron/gadgetron/wiki/Linux-Installation-(Gadgetron-4)).  
 
## Potential issue
 
### add-apt-repository: command not found
 
Fresh Ubutnu installations might not come with the `add-apt-repository` command installed. It's part of the `software-properties-common` package, and can simply be installed:  
```bash
sudo apt-get install software-properties-common
```

### pip3: command not found

If you have not done a lot of Python work, you might not have pip install (it's a package manager for Python).
```bash
sudo apt-get install python3-pip
```

### Integrating Matlab running in Windows with Gadgetron in WSL

The Gadgetron Foreign Language interface will look on your PATH to find `matlab` in order to start a Matlab process. If you are not keen on installing Matlab in you WSL instance, you can add a simple script to run your Windows native Matlab in stead. 

Add the following to a file called 'matlab', and place it somewhere on the Ubuntu path (`~/.local/bin` will do). Run `chmod u+x matlab` to mark the script as executable. 
```bash
#!/bin/bash
export WSLENV=GADGETRON_EXTERNAL_PORT:GADGETRON_EXTERNAL_MODULE
matlab.exe $@
```

Test the script by typing entering `matlab` in a terminal - your Windows Matlab should start as a result. If it does not, you might have to make sure `matlab.exe` is on your Windows [path](https://helpdeskgeek.com/windows-10/add-windows-path-environment-variable/).  
