##############################################################################
#
#   TANDEM PAS:
#   "Small set of rules to produce an approriate set of tandem poly(A) sites
#   from the full annotation of sites from PolyASite and a provided gtf file"
#
#   AUTHOR: Ralf_Schmidt
#   MODIFICATIONS: Maciej_Bak, C.J. Herrmann, M. Zavolan
#   AFFILIATION: University_of_Basel
#   AFFILIATION: Swiss_Institute_of_Bioinformatics
#   CONTACT: mihaela.zavolan@unibas.ch
#   CREATED: 28-03-2020
#   MODIFIED: 21-09-2021
#   LICENSE: Apache_2.0
#
##############################################################################

import os
import traceback
from snakemake.utils import makedirs

################################################################################
### Local rules
################################################################################

localrules: all, create_log_dir, select_terminal_exon_pas

logs = config["logdir"]
cluster_logs = os.path.join(logs, "cluster_logs")

##############################################################################
### Target rule with final output of the pipeline
##############################################################################

rule all:
    """
    Gathering all output
    """
    input:
        tandem_pas_TE = expand(os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.terminal_exons.{strandedness}.bed"),
                strandedness = config["strandedness"]),

    
rule create_log_dir:
    ## LOCAL ##
    ''' This step creates the log directory, if necessary.
    This is required when jobs are submitted to cluster and the
    job output should be written to these files.
    '''
    output:
        TMP_out = temp(os.path.join(logs,"created_dirs.tmp"))
    run:
        makedirs( cluster_logs )
        shell("touch {output.TMP_out}")


##############################################################################
### Select tandem poly(A) sites
##############################################################################

rule select_tandem_pas:
    """
    Selecting only pas which may be categorized as proximal/distal.
    """
    input:
        created_dirs = os.path.join(logs,"created_dirs.tmp"),
        BED_pas_atlas = config['polyasites'],
        GTF_annotation = config['gtf'],
        SCRIPT_ = os.path.join(
            config['scriptsdir'],
            "mz-select-pas-subset.pl")

    output:
        TSV_tandem_pas = os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.tsv")

    params:
        STR_biotype_key = lambda wildcards:
            "--type_id=" + config['biotype_key'] if 'biotype_key' in config else "",
        STR_biotype_values = lambda wildcards:
            " ".join(["--type=" + i for i in config['biotype_values']]) if "biotype_values" in config else "",
        FLT_min_support = config['min_support'],
        INT_three_prime_offset = config["three_prime_offset"],
        INT_locus_extension = config["locus_extension"],
        cluster_log = os.path.join(cluster_logs,
            str(config["atlas_version"]) + ".select_tandem_pas.log"
        )
        

    log:
        os.path.join( logs,
            str(config["atlas_version"]) + ".select_tandem_pas.log"
        )

    singularity:
        "docker://perl:5.26.2"

    conda:
        "env/perl.yaml"

    shell:
        """
        perl {input.SCRIPT_} \
        --minLevel={params.FLT_min_support} \
        --annotation={input.GTF_annotation} \
        {params.STR_biotype_key} \
        {params.STR_biotype_values} \
        --offset={params.INT_three_prime_offset} \
        --locusExtension={params.INT_locus_extension} \
        --nonredundant \
        {input.BED_pas_atlas} \
        1> {output.TSV_tandem_pas} \
        2> {log}
        """

##############################################################################
###  select tandem poly(A) sites of terminal exons
##############################################################################

rule select_terminal_exon_pas:
    """
    Filter pas and select only those on terminal exons
    """
    input:
        TSV_tandem_pas = os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.tsv")

    output:
        TSV_tandem_pas_terminal_exons = os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.terminal_exons.tsv")

    params:
        cluster_log = os.path.join(cluster_logs,
            str(config["atlas_version"]) + ".select_terminal_exon_pas.log"
        )

    log:
        os.path.join( logs,
            str(config["atlas_version"]) + ".select_terminal_exon_pas.log"
        )

    run:
        with open(input.TSV_tandem_pas, "r") as ifile, open(output.TSV_tandem_pas_terminal_exons, "w") as ofile, open(log[0], "w") as logfile:
            try:
                for line in ifile:
                    # check if the exon that contains a given pas is
                    # indeed the last exon of a transcript
                    F = line.rstrip().split("\t")
                    ex_id, ex_nr, total_exons, ex_start, ex_end = F[8].split(":")
                    if int(total_exons) == int(ex_nr):
                        ofile.write(line)
            except Exception:
                traceback.print_exc(file = logfile)
                raise Exception(
                    "Workflow error at rule: select_terminal_exon_pas"
                )

##############################################################################
### Filter pas based on the annotation
##############################################################################

rule filter_on_ambiguous_annotation:
    """
    Intersect tandem poly(A) sites of terminal exons with the annotation.
    Only retain exons that can be associated to a gene unambiguously.
    Create separate files to be used with stranded and unstranded input data
    """
    input:
        TSV_tandem_pas_terminal_exons = os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.terminal_exons.tsv"),
        GTF_annotation = config['gtf'],
        SCRIPT_ = os.path.join(
            config["scriptsdir"],
            "mz-remove-overlapping-genes_{strandedness}.pl")

    output:
        BED_tandem_pas_terminal_exons_clean = os.path.join(config["outdir"],
                str(config["atlas_version"]) + ".tandem_pas.terminal_exons.{strandedness}.bed")

    params:
        INT_downstream_extend = config['downstream_extend'],
        cluster_log = os.path.join(cluster_logs,
            str(config["atlas_version"]) + "filter_{strandedness}.log"
        )

    log:
        os.path.join( logs,
                        str(config["atlas_version"]) + ".filter_{strandedness}.log")

    singularity:
        "docker://perl:5.26.2"

    conda:
        "env/perl.yaml"

    shell:
        """
        perl {input.SCRIPT_} \
        --tandemPAS={input.TSV_tandem_pas_terminal_exons} \
        --downstream_extend={params.INT_downstream_extend} \
        {input.GTF_annotation} \
        1> {output.BED_tandem_pas_terminal_exons_clean} \
        2> {log}
        """


#-------------------------------------------------------------------------------
# How did it go?
#-------------------------------------------------------------------------------
onsuccess:
    print("Workflow finished, no error")

onerror:
    print("An error occurred, check log at %s." % {log})
