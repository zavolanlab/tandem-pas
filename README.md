
# Tandem Poly(A) Sites

A small [Snakemake][snakemake] workflow to extract a set of tandem poly(A) sites (= sites on transcripts with more than one known poly(A) site) from the [PolyASite atlas][polyasite-atlas] (BED) and a genomic annotation (GTF). The output bed files from this pipeline can be used to run [PAQR][paqr].

![rule_graph][rule-graph]

# Installation

## 1. Clone the repository

Go to the desired directory/folder on your file system, then clone/get the 
repository and move into the respective directory with:

```bash
git clone git@github.com:zavolanlab/tandem-pas.git
cd tandem-pas
```

## 2. Conda installation

Workflow dependencies can be conveniently installed with the [Conda][conda]
package manager. We recommend that you install [Miniconda][miniconda-installation] 
for your system (Linux). Be sure to select Python 3 option. 

## 3. Dependencies installation

For improved reproducibility and reusability of the workflow,
each individual step of the workflow runs either in its own [Singularity][singularity]
container OR in its own [Conda][conda] virtual environemnt. 
As a consequence, running this workflow has very few individual dependencies. 
The **container execution** requires Singularity to be installed on the system where the workflow is executed. 
As the functional installation of Singularity requires root privileges, and Conda currently only provides Singularity
for Linux architectures, the installation instructions are slightly different depending on your system/setup:

### For most users

If you do *not* have root privileges on the machine you want
to run the workflow on *or* if you do not have a Linux machine, please [install
Singularity][singularity-install] separately and in privileged mode, depending
on your system. You may have to ask an authorized person (e.g., a systems
administrator) to do that. This will almost certainly be required if you want
to run the workflow on a high-performance computing (HPC) cluster. 

After installing Singularity, or should you choose not to use containerization but only conda environments, install the remaining dependencies with:
```bash
conda env create -f install/environment.yml
```


### As root user on Linux

If you have a Linux machine, as well as root privileges, (e.g., if you plan to
run the workflow on your own computer), you can execute the following command
to include Singularity in the Conda environment:

```bash
conda env create -f install/environment.root.yml
```

## 4. Activate environment

Activate the Conda environment with:

```bash
conda activate tandem_pas
```


### 5. Configure the input parameters
The file "configs/config.yaml" contains all information about used parameter values, data locations, file names and so on. During a run, all steps of the pipeline will retrieve their paramter values from this file. It follows the yaml syntax (find more information about yaml and it's syntax [here](http://www.yaml.org/)) making it easy to read and edit. The main principles are:
  - everything that comes after a `#` symbol is considered as comment and will not be interpreted
  - paramters are given as key-value pair, with `key` being the name and `value` the value of any paramter


Some entries require your editing while most of them you can leave unchanged. However, this config file contains all parameters used in the pipeline and the comments should give you the information about their meaning. If you need to change path names please ensure to **use relative instead of absolute path names**.

### 6. Annotations and poly(A) sites
Download the [PolyASite atlas][polyasite-atlas] and gene annotations (e.g. from [ensembl][ensembl]) for your organism and specify their paths in the `config.yaml`. 
> NOTE: the pipeline will only work if the poly(A) sites file and annotation gtf use the same chromosome naming scheme. For PolyASite 2.0 derived files, this means that ensembl annotations have to be used (lacking the leading "chr"). However, as gencode annotations are based on ensembl, you could possibly - **AT YOUR OWN RISK** - remove the "chr" from *gencode* annotations before running the pipeline with
```
awk -F'\t' -vOFS='\t' '{ gsub("chr","",$1) ; print}' gencode.gtf > gencode.chr_removed.gtf
``` 

### 7. Running the pipeline
Go to the root folder of this repo and make sure you have the conda environment `tandem_pas` activated. For your convenience, the directory `execute` contains bash scripts that can be used to start local runs, using either singularity or conda, and a slurm cluster run, using singularity.

[polyasite-atlas]: <https://polyasite.unibas.ch/atlas>
[conda]: <https://docs.conda.io/projects/conda/en/latest/index.html>
[miniconda-installation]: <https://docs.conda.io/en/latest/miniconda.html>
[rule-graph]: images/dag.svg
[snakemake]: <https://snakemake.readthedocs.io/en/stable/>
[singularity]: <https://sylabs.io/singularity/>
[singularity-install]: <https://sylabs.io/guides/3.5/admin-guide/installation.html>
[slurm]: <https://slurm.schedmd.com/documentation.html>
[ensembl]: <https://www.ensembl.org/index.html>
[paqr]: <https://github.com/zavolanlab/PAQR_KAPAC>