#!/bin/bash
# comp-star-rsem 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of star_log: '$star_log'"
    echo "Value of star_bam: '$star_bam'"
    echo "Value of rsem_isoform_quant: '$rsem_isoform_quant'"
    echo "Value of rsem_gene_quant: '$rsem_gene_quant'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$star_log" -o star_log

    dx download "$star_bam" -o star_bam

    dx download "$rsem_isoform_quant" -o rsem_isoform_quant

    dx download "$rsem_gene_quant" -o rsem_gene_quant

    # Fill in your application code here.
    #
    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.
    echo Log.final.out
    diff <(awk 'NR>4{print}' $1/Log.final.out) <(awk 'NR>4{print}' $2/Log.final.out) | head

    echo Aligned.sortedByCoord.out.bam
    diff  <(samtools view $1/Aligned.sortedByCoord.out.bam) <(samtools view $2/Aligned.sortedByCoord.out.bam) | head

    echo Quant.isoforms.results
    diff  <(cut -f1-8 $1/Quant.isoforms.results) <(cut -f1-8 $2/Quant.isoforms.results) | head
    echo Quant.genes.results
    diff  <(cut -f1-7 $1/Quant.genes.results) <(cut -f1-7 $2/Quant.genes.results)| head

    for ii in `cd $1; ls *bw`
    do
        echo $ii
        diff $1/$ii $2/$ii | head
    done

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.

    log_diff=$(dx upload log_diff --brief)
    isoform_quant_diff=$(dx upload isoform_quant_diff --brief)
    gene_quant_diff=$(dx upload gene_quant_diff --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output log_diff "$log_diff" --class=file
    dx-jobutil-add-output bam_diff "$bam_diff" --class=boolean
    dx-jobutil-add-output isoform_quant_diff "$isoform_quant_diff" --class=file
    dx-jobutil-add-output gene_quant_diff "$gene_quant_diff" --class=file
    dx-jobutil-add-output bigwig_diff_pass "$bigwig_diff_pass" --class=boolean
}