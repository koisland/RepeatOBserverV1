# os stands for operating system. It's a common module for doing os things.
import os
# Glob allows you to iterate thru a bunch files. It's this character *
import glob

input_dir = "asm/hifiasm"
# We use this glob to fill in the wildcards we need.
fasta_glob = os.path.join(input_dir, "{sm}.{hap}~hifiasm.fasta")

# {} extracts the part of the path
wcs = glob_wildcards(fasta_glob)


rule run_repeatobserver:
    # Snakemake checks for input at start. Doesn't run without.
    input:
        fasta_glob
    # Checks that output exists after every job. If doesn't crashes.
    # If finished and need to rerun. Won't run same job.
    output:
        "output_chromosomes/{sm}_{hap}-AT/Summary_output/Shannon_div/{sm}_{hap}-AT_Shannon_centromere_range.txt"
    threads:
        20
    resources:
        mem_mb=128000
    conda:
        "repeatobserver"
    log:
        "logs/run_repeatobserver_{sm}_{hap}.log"
    shell:
        """
        # -g stands for AT walk.
        bash Setup_Run_Repeats.sh \
        -i {wildcards.sm} \
        -f {input} \
        -h {wildcards.hap} \
        -c {threads} \
        -m {resources.mem_mb} \
        -g FALSE
        """


# The final rule. What's expected at the end of the run.
rule all:
    input:
        # Zip makes sure combination in order.
        expand(rules.run_repeatobserver.output, zip, sm=wcs.sm, hap=wcs.hap)
    default_target:
        True
