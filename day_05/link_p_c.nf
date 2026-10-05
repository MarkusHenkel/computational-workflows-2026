#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug true

    input:
        val row
    
    script:
    def block_size = row["block_size"]
    def in_str = row["input_str"]
    def out_name = row["out_name"]
    // turn string into list, collate into lists of size block_size and turn back into strings
    def chunks = in_str.toList().collate(block_size).collect{v -> v.join()}

    """
    
    """


} 

process CONVERTTOUPPER {
    debug true


} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    samplesheet = channel.fromPath('samplesheet_2.csv')
            .splitCsv(header: true)
            .view()
    
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    SPLITLETTERS(samplesheet)
    
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory



}