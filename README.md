# GadgetronOnlineClass

During June 2020 we will host the “**GadgetronOnlineClass**”. Although initially scheduled to take place in Bordeaux as a Summer School, the COVID-19 situation made that impossible. We are instead hosting it online. 

This course is aimed at both new and experienced users of **Gadgetron**, covering basic reconstruction as well as the latest functionalities. The topics covered are intended for researchers in basic science and/or clinical research. The online course will also provide examples of how to use the vendor-agnostic **MRD** file format (formerly “**ISMRMRD**”) for your custom reconstructions.

The course is organised remotely and will be accessible in live via **videoconference**. In addition of the course and pratical course, participants will have the possibility to propose work on a MRI reconstruction topic during **interactive session** with the speakers. Please, go to this [page](Interactive-Sessions) for more information, we encourage you to apply.

The Gadgetron Online Course is made of several modules that constitute together the scientific stack. Gadgetron made use of standard computing languages (C++, Cmake, CUDA, Python, Matlab) that are themselve calling hundreds of libraries/packages/functions. We won't cover everything in this short course, but you should get enough information to decide if your research can benefit from Gadgetron. And I bet it will likely do.

For any questions, feel to contact us on the [forum](https://groups.google.com/forum/#!forum/gadgetron) of Gagdetron or at gadgetron2020 /at/ sciencesconf.org

Organizers: David Hansen, Kristoffer Knudsen, Hui Xue, Oliver Josephs, Vinai Roopchansingh, John Derbyshire, Adrienne Campbell, Rajiv Ramasawmy, Aurélien Trotier, Stanislas Rapacchi, Maxime Yon, Pierre Bour, Valéry Ozenne

## Registration

Please follow the [registration link](https://gadgetron2020.sciencesconf.org/registration). Registration is free. We will use the platform dedicated to the initial summer school for the registration process and email communication. Otherwise please refer to the GitHub website [GadgetronOnlineClass](https://github.com/gadgetron/GadgetronOnlineClass). Thanks for your comprehension.

## Agenda

### Day 1 : Gadgetron Introduction

> <img src="https://img.shields.io/badge/-_Warning-orange.svg?style=flat-square"/>
> Note that the time are defined in the Central European Summer Time (CEST) zone.

Date  | Time | Link | Topic | Tutor
----- | ---- | ----- | ----- | -----
June 11, 2020 | 13:45-14:00 | | [Welcome] | Valéry Ozenne
June 11, 2020 | 14:00-14:30 | [link](Courses/Day1/Lecture1) | [A tour of Gadgetron] | David Hansen
June 11, 2020 | 14:30-15:30 | [link](Courses/Day1/Lecture2) | [Practical introduction to Gadgetron] | Kristoffer Knudsen
June 11, 2020 | 15:30-15:40 |  | [Break]
June 11, 2020 | 15:40-17:00 | [link](Courses/Day1/Lecture3) | [Basic reconstruction using Python] | Valery Ozenne
June 11, 2020 | 17:00-18:00 | [link](Courses/Day1/QandA) | [Q&A] | Everybody

### Day 2 : MRD, a vendor-agnostic file format for MRI reconstruction (or toward the scanner room) 

Date  | Time | Place | Topic | Tutor
----- | ---- | ----- | ----- | -----
June 18, 2020 | 14:00-15:00 | [link](Courses/Day2/Lecture1) | [MRD Part 1: Introduction] | Maxime Yon  
June 18, 2020 | 15:00-16:00 | [link](Courses/Day2/Lecture2) | [MRD Part 2: ]Siemens/GE/Bruker raw data conversion to MRD through XML style sheets, and working with HDF5 files] | Vinai Roopchansingh & J. Andrew Derbyshire
June 18, 2020 | 16:00-17:00 | [link](Courses/Day2/Lecture3) | [Communication process with the Siemens scanner] | Hui Xue 
June 18, 2020 | 17:00-18:00 | [link](Courses/Day2/QandA) | [Q&A] | Everybody
 
### Day 3 : Foreign-Language-Interface 

Date  | Time | Place | Topic | Tutor
----- | ---- | ----- | ----- | -----
June 25, 2020 | 14:00-15:00 | [link](Courses/Day3/Lecture1) | [Foreign-Language-Interface ] | Kristoffer Knudsen
June 25, 2020 | 15:00-16:30 | [link](Courses/Day3/Lecture2) | [Protyping at the scanner with MATLAB part 1] |  Oliver Josephs  
June 25, 2020 | 16:00-17:00 | [link](Courses/Day3/Lecture3) | [Protyping at the scanner with MATLAB part 2] | Aurelien Trotier & Stan Rapacchi 
June 25, 2020 | 17:00-18:00 | [link](Courses/Day3/QandA) | [Q&A] | Everybody

### Day 4 : C++ 

Date  | Time | Place | Topic | Tutor
----- | ---- | ----- | ----- | -----
July 2, 2020 | 14:00-15:00 | [link](Courses/Day4/Lecture1) | [How to write a C++ Gadget ] | David Hansen
July 2, 2020 | 15:00-16:30 | [link](Courses/Day4/Lecture2) | [The Generic Cartesian Chain and toolboxes] | Hui Xue
July 2, 2020 | 16:00-17:00 | [link](Courses/Day4/Lecture3) | [To be announced] | Adrienne Campbell 
July 2, 2020 | 17:00-18:00 | [link](Courses/Day4/QandA) | [Q&A] | Everybody

## Participate to Online Course Agenda (Preparation and Modalities)

To achieve good interaction between lecturers and participants - and especially tutors and participants in the work in progress sessions - we highly recommand to read the preparation list.

Preparation list for speakers is available [here](Preparation#preparation-information-for-participant).

Preparation list for participants [here](Preparation#preparation-information-for-the-organiser). 	


## Website Structure

All information will be written in a README file in each directories. Additionnal contents like data, codes, powerpoint will be uploaded or indicated in the material folder for each lecture 

```bash

├── Courses
│   ├── Day1
│   │   ├── Lecture1
│   │   │   └── README.md
│   │   ├── Lecture2
│   │   │   └── README.md
│   │   └── Lecture3
│   │       └── README.md
│   ├── Day2
│   │   ├── Lecture2
│   │   │   └── README.md
│   └── Day3
├── Installation
│   └── README.md
├── Interactive-Sessions
│   └── README.md
├── Preparation
│   └── README.md
└── README.md

```


## Test the MRD and Gadgetron installation in advance

Since all participants are working at home on their own computer, we asked the participants to test their MRD and Gadgetron installation in advance. 
Detailed installation instructions has been summarized [here](Installation).  

Feel free to contact us and to post any inquiries on the gadegtron [forum](https://groups.google.com/forum/#!forum/gadgetron)

> <img src="https://img.shields.io/badge/-_Warning-orange.svg?style=flat-square"/>
> Note that this course is based on the following teaching material: 
> Tutorial with docker [link](http://gadgetron.github.io/tutorial/) 
> Tutorial Hello word [link](https://github.com/gadgetron/gadgetron/wiki/Gadgetron-Hello-World)
> Running one of them before is highly recommended

## 1. Introduction courses (day 1 : June 11th 2020)

### 1.1 - Gadgetron, a high level overview introduction(14:00 -> 14:30 CEST)

This [lecture](introduction-part1.md) does not attempt to be comprehensive and cover every single feature, or even every commonly used feature. Instead, it introduces many of Gadgetron's most noteworthy features, and will give you a good idea of Gadgetron's capability and usage.

**See also**:

 * [wiki](https://github.com/gadgetron/gadgetron/wiki/Gadgetron-Gadgets)


### 1.2 - Introduction (14:30 -> 15:30 CEST)

This [lecture](Coureses/Day1/Lecture2) is a Practical Introduction to Gadgetron. It takes a very hand-on approach to getting started with Gadgetron, aimed at giving new users the information they need to assemble and run their own reconstructions using Gadgetron.

This lecture will cover starting and running Gadgetron, controlling Gadgetron behaviour through configuration files, and provide a sensible introduction to a handful of very common Gadgets. 

**See also**:

 * [Gadgetron Hello World](https://github.com/gadgetron/gadgetron/wiki/Gadgetron-Hello-World)

### 1.3 - Basic reconstruction using Python  (15:40 -> 17:00 CEST)

The primary goal of this [lecture](Courses/Day1/Lecture3) introduces the python gadget and the ismsmrd-python-toolboxes that contains various toolboxes dedicated to common issues. Its different submodules correspond to different applications, such as fourier transfrom, coil sensitivity map estimation, grappa reconstruction, etc.

### 1.4 - Q&A



**See also**:

  * []()
  * []()
  * []()

### 1.4 - Basic reconstruction using Python  (17:00 -> 18:00 CEST)

## 2. MRD, a vendor-agnostic file format for MRI reconstruction (or toward the scanner room)   (day 2: June 18th)

### 2.1 - Title  (  )

This [lesson](Courses/Day2/Lecture1) introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


### 2.2 - Siemens/GE/Bruker raw data conversion to MRD through XML style sheets, and working with HDF5 files

This session discusses how the conversion process in ISMRMRD utilizes style sheets to convert the vendors' proprietary formats and data values to the fully and openly documented ISMRMRD format.  There will also be an interactive demonstration of working with HDF5 files in a Jupyter notebook environment with
Python 3.

**See also**:

  * [HDF5 for Python](https://www.h5py.org)
  * [Juypter Notebooks](https://jupyter.org)


### 2.3 - Title  (  )

This [lesson]() introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


## 3. Foreign-Language-Interface  (day 2: June 25th)

### 3.1 - Title  (  )

This [lesson](Courses/Day3/Lecture1) introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


### 3.2 - Title  (  )

This [lesson](Courses/Day3/Lecture2) introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


### 3.3 - Title  (  )

This [lesson]() introduces ...

**See also**:

  * [ ]( )
  * [ ]( )



## 4. C++  (day 4: July 2nd)

### 4.1 - Title  (  )

This [lesson](Courses/Day3/Lecture1) introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


### 4.1 - Title  (  )

This [lesson](Courses/Day3/Lecture2) introduces ...

**See also**:

  * [ ]( )
  * [ ]( )


### 4.1 - Title  (  )

This [lesson]() introduces ...

**See also**:

  * [ ]( )
  * [ ]( )








## External links 

[Git]:        https://git-scm.com
[Docker]:     https://docs.docker.com/get-docker/
[Python]:     http://www.python.org
[Numpy]:      http://www.numpy.org
[Scipy]:      http://www.scipy.org
[Matplotlib]: http://matplotlib.org

The driving themes of the Gadgetron are notably cardiac imaging, interventional imaging, MR-PET imaging, high field and low field imaging. Here are some works done using the Gadgetron.  The list is non-exhaustive.

* kt-SENSE, non-Cartesian, iterative SENSE, sequence: golden angle radial bSSFP projections. [link](https://jcmr-online.biomedcentral.com/articles/10.1186/1532-429X-18-S1-P329)
* 3D l1-SPIRiT Reconstruction on Gadgetron based Cloud. [link](http://www.forskningsdatabasen.dk/en/catalog/2389264072)
* Integration of the BART into Gadgetron for Inline Cloud-Based Reconstruction. [link](http://archive.ismrm.org/2018/2861.html)
* MR Fingerprinting using a Gadgetron-based reconstruction . [link](http://archive.ismrm.org/2018/3525.html)
* Cardiac MR Fingerprinting in Gadgetron for Online Reconstruction. [link](http://archive.ismrm.org/2018/3525.html)
* TPVM Tissue Phase velocity mapping, Spiral trajectory. [link](https://jcmr-online.biomedcentral.com/articles/10.1186/1532-429X-16-S1-W31)
* Spiral imaging with off-resonance reconstruction. [link](https://jcmr-online.biomedcentral.com/articles/10.1186/1532-429X-18-S1-P216)
* 4D DCE MRI, Free-Breathing Liver Perfusion. Spiral trajectory + GRAPPA. [link](http://archive.ismrm.org/2018/5640.html)
* SMS T1 mapping. [link](https://hal-amu.archives-ouvertes.fr/hal-01784726/document)
* Multi-vendor Hyperpolarised 13C analysis . [link](https://www.forskningsdatabasen.dk/en/catalog/2284922562)
* Full Free-Breathing Protocol for CMR. [link](https://link.springer.com/article/10.1186/1532-429X-18-S1-P313)
* In-line cardiac perfusion mapping [link](https://heart.bmj.com/content/103/Suppl_1/A4.1?utm_source=trendmd&utm_medium=cpc&utm_campaign=heart&utm_content=consumer&utm_term=1-B), [link](https://jcmr-online.biomedcentral.com/articles/10.1186/1532-429X-18-S1-W8), [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/2979.html)
* In-line cardiac perfusion and deep learning [link](https://arxiv.org/abs/1910.07122)
* MR-PET imaging : SIRF [link](https://www.sciencedirect.com/science/article/pii/S0010465519303984)
* MR-PET imaging : respiratory and cardiac motion correction, reco: joint Compressed Sensing reconstruction. [link](https://www.ncbi.nlm.nih.gov/pubmed/28800546)
* MR-PET imaging : 4D CBCT-based proton dose calculation. [link](https://www.ncbi.nlm.nih.gov/pubmed/30448049)
* Temperature mapping. [link](https://www.ncbi.nlm.nih.gov/pubmed/26899165), [link](https://www.sciencedirect.com/science/article/pii/S0730725X19306605)
* ARFI: sequence single-shot gradient EPI, reco GRAPPA. [link](https://www.ncbi.nlm.nih.gov/pubmed/28090656)
* Highly accelerated cardiac cine : bFISTA‐SPIRiT et bFISTA‐SENSE. [link](https://onlinelibrary.wiley.com/doi/abs/10.1002/mrm.26224)
* Low field magnetic resonance imaging scanner for cardiac imaging. [link](https://patents.google.com/patent/US20180259604A1/en)
* Augmented Reality [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/0598.html), [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/3417.html)
* Cardiac diffusion, GRAPPA. [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/4767.html)
* Neuro Diffusion,3D multi-shot-EPI avec PF. [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/2129.html)
* Coronary magnetic resonance angiography, variable density sampling + Compress Sensing. [link](https://index.mirasmart.com/ISMRM2018/PDFfiles/0918.html)
* Real-time feedback 3DEPI fMRI, Matlab SENSE reconstruction [link](https://academic.oup.com/braincomms/advance-article/doi/10.1093/braincomms/fcaa049/5824291)

