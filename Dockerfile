FROM groovy

MAINTAINER Gregor Rot <gregor.rot@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Zurich
ENV MPLLOCALFREETYPE=1
USER root
RUN apt update
RUN apt-get install -y libpng-dev
RUN apt-get install -y pkg-config
RUN apt-get install -y vim
RUN apt-get install -y python3
RUN apt-get install -y git
RUN apt-get install -y python3-pip
RUN apt-get install -y rna-star
RUN apt-get install -y samtools
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libssl-dev
RUN pip3 install pysam
RUN pip3 install numpy
RUN pip3 install matplotlib==3.2
RUN pip3 install regex
RUN pip3 install pandas
RUN pip3 install scipy
RUN pip3 install HTSeq

# R
RUN apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran39/'
RUN apt install -y r-base r-base-core r-recommended r-base-dev
RUN R -e 'install.packages("BiocManager")'
RUN R -e 'BiocManager::install("edgeR")'
RUN R -e 'BiocManager::install("DEXSeq")'
RUN R -e 'install.packages("data.table")'
RUN R -e 'BiocManager::install("GenomicRanges")'
RUN R -e 'BiocManager::install("Biostrings")'
RUN R -e 'BiocManager::install("GenomicAlignments")'
RUN R -e 'BiocManager::install("dplyr")'
RUN R -e 'BiocManager::install("openxlsx")'
RUN R -e 'BiocManager::install("reshape2")'
RUN R -e 'BiocManager::install("tracklayer")'
RUN R -e 'BiocManager::install("DESeq2")'
RUN R -e 'BiocManager::install("GenomicFeatures")'
RUN R -e 'BiocManager::install("tidyr")'
RUN apt-get install -y  default-jre
RUN apt-get install -y sambamba
# apauser
RUN useradd -m -d /home/apauser apauser

RUN chown -R apauser.apauser /home/apauser
RUN R -e 'BiocManager::install("BSgenome.Hsapiens.UCSC.hg19")'
RUN R -e 'BiocManager::install("BSgenome.Mmusculus.UCSC.mm9")'
USER apauser
WORKDIR /home/apauser
RUN mkdir ~/data
RUN echo "alias python='python3'" >> ~/.bashrc
RUN ls

# salmon
RUN mkdir ~/software
RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v1.4.0/salmon-1.4.0_linux_x86_64.tar.gz -O ~/software/salmon.tgz
WORKDIR /home/apauser/software
RUN tar xfz salmon.tgz
RUN rm salmon.tgz
RUN mv salmon-latest_linux_x86_64/ salmon

#bbmap

RUN cd ~/software
RUN wget https://cfhcable.dl.sourceforge.net/project/bbmap/BBMap_39.01.tar.gz
RUN tar -xzf BBMap_39.01.tar.gz
RUN rm BBMap_39.01.tar.gz

#fastqc

RUN cd ~/software
ADD tools/fastqc_v0.11.9.zip .
RUN unzip fastqc_v0.11.9.zip
RUN rm fastqc_v0.11.9.zip
RUN chmod 755 FastQC/fastqc

#star

RUN cd ~/software
RUN wget https://github.com/alexdobin/STAR/archive/2.7.10b.tar.gz
RUN tar -xzf 2.7.10b.tar.gz
RUN rm 2.7.10b.tar.gz


# paths
RUN echo "export PATH=$PATH:/home/apauser/apa/bin:/home/apauser/pybio/bin:~/software/salmon/bin:/home/apauser/software/FastQC:/home/apauser/software/bbmap:/home/apauser/software/STAR-2.7.10b/bin/Linux_x86_64_static" >> ~/.bashrc
RUN echo "export PYTHONPATH=$PYTHONPATH:/home/apauser" >> ~/.bashrc

WORKDIR /home/apauser

# pybio
RUN git clone https://github.com/grexor/pybio.git
RUN ln -s /home/apauser/data /home/apauser/pybio/genomes/data
RUN echo "pybio.path.genomes_folder='/home/apauser/pybio/genomes/data/genomes'" >> /home/apauser/pybio/config/config.txt
