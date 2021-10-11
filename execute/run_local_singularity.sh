# Run the pipeline on a local machine using singulartiy

snakemake \
--configfile config.yaml \
--printshellcmds \
--use-singularity \
--singularity-args "--bind '${PWD}/../'" \
--cores 4 \
&> tpas.local.singu.log
