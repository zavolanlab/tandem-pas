# Run the pipeline on slurm using singularity

snakemake \
--configfile configs/config.yaml \
--printshellcmds \
--use-singularity \
--singularity-args "--bind '${PWD}/../'" \
--cluster-config configs/cluster_config.json \
--cores 500 \
--local-cores 10 \
--cluster "sbatch \
	--cpus-per-task {cluster.threads} \
	--mem {cluster.mem} \
	--qos {cluster.queue} \
	--time {cluster.time} \
	-o {params.cluster_log} \
	--export=JOB_NAME={rule} \
	--open-mode=append" \
	--jobs 20 \
&> tpas.slurm.singu.log
