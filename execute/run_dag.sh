# Create the DAG (Directed Acyclic Graph)

snakemake \
--use-conda \
--configfile config.yaml \
-np --dag \
| dot -Tsvg \
> images/dag.svg