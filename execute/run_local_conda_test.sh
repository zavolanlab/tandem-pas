# Run the pipeline on a local machine using conda envs

snakemake \
--configfile tests/integration/config.yaml \
--printshellcmds \
--use-conda \
--cores 1 \
&& \
rm -rf results \
&& \
echo "Test completed successfully"
