# Create the DAG (Directed Acyclic Graph)

snakemake \
--use-conda \
--configfile configs/config.yaml \
-np --dag \
| dot -Tsvg \
> images/dag.svg