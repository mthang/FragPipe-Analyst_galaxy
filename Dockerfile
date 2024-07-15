# syntax=docker/dockerfile:1
FROM rocker/shiny-verse:4.2.1
RUN apt-get update && apt-get install -yq \
    libbz2-dev \
    libhdf5-dev \
    libnetcdf-dev \
    build-essential \
    libgd-dev \
    libudunits2-dev \
    libproj-dev \
    libgdal-dev  \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-extra

RUN Rscript -e 'install.packages(c("devtools", "BiocManager","tidyverse", "ggrepel", "httr", "rjson", "mvtnorm", "tmvtnorm", \
"imputeLCMD", "plotly", "DT", "testthat", "RColorBrewer", "shiny","shinyalert","shinydashboard", \
"shinyjs", "svglite", "rhandsontable", "shinyBS", "shinyWidgets", "ggVennDiagram", "conflicted", "png", "vegan", "assertthat", \
"shinycssloaders","shiny.info","UpSetR","factoextra"), dependencies=TRUE)'
### #FROM bioconductor/bioconductor_docker:RELEASE_3_15
RUN Rscript -e 'BiocManager::install(pkgs=c("ensembldb","fdrtool", "EnsDb.Hsapiens.v86", "SummarizedExperiment", "limma", "ComplexHeatmap", "impute", "pcaMethods"), ask=F, dependencies=TRUE)'


# Install jsonlite in R:
RUN Rscript -e 'install.packages("jsonlite", repos = c("https://jeroen.r-universe.dev", "https://cloud.r-project.org"))'


### fix
COPY . /srv/shiny-server
COPY shiny-server.conf.prod /etc/shiny-server/shiny-server.conf
COPY entrypoint.sh /

# disable shiny-server
RUN touch /etc/services.d/shiny-server/down

RUN chmod -R +r /srv/shiny-server

RUN chmod -R ugo+wrX /var/log/shiny-server/

RUN chown -R shiny:shiny /srv/shiny-server/

RUN chmod o+w /usr/local/lib/R/site-library

RUN chmod +x entrypoint.sh

#USER shiny

CMD ["/entrypoint.sh", "/usr/bin/shiny-server"]

### RUN Rscript -e 'install.packages("renv")'
#COPY ./ /srv/shiny-server/fragpipe-analyst
#COPY shiny-server.conf.prod /etc/shiny-server/shiny-server.conf

### WORKDIR /srv/shiny-server/fragpipe-analyst
### RUN Rscript -e 'renv::init()' # This is already run and pushed to github.
### RUN Rscript -e 'renv::restore()'
### RUN Rscript -e 'renv::isolate()'
#RUN chmod -R +r /srv/shiny-server/fragpipe-analyst
