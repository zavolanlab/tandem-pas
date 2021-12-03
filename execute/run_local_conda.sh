# Run the pipeline on a local machine using conda envs

snakemake \
--configfile config.yaml \
--printshellcmds \
--use-conda \
--cores 4 \
&> tpas.log
