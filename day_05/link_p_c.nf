#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug true

    input:
        val row
    
    output:
        path "${row["out_name"]}_*.txt", emit: chunk_files

    script:
    def block_size = row["block_size"]
    def in_str = row["input_str"]
    def out_name = row["out_name"]

    """
    #!/usr/bin/env python3 

    chunks = []
    for i in range(0, len("${in_str}"), ${block_size}):
        chunks.append("${in_str}"[i : ${block_size}+i])
    
    filepaths = []
    for i, chunk in enumerate(chunks):
        filepath = f"${out_name}_{i+1}.txt" 
        with open(filepath, "w") as file:
            file.write(chunk)
            print(f"File created: {file.name}")
        filepaths.append(filepath)

    """


} 

process CONVERTTOUPPER {
    debug true

    input:
        path chunk_files
        val results_dir
    
    output:
        path "${results_dir}/*", emit: outfiles

    script:
    // python lists have the schema ["item1", "item2"], groovy lists dont => convert between the two
    def chunk_files_string = chunk_files.collect{v->"'${v}'"}.join(", ")
    def chunk_files_list = "[" + chunk_files_string + "]"
    """
    #!/usr/bin/env python3

    import os

    # read chunks from file
    for chunk_file in ${chunk_files_list}:
        # open file for getting the file content line by line
        with open(chunk_file, "r") as read_file:
            lines = read_file.readlines()

        
        # open results file for writing the uppercase chunks inside it
        os.makedirs("${results_dir}", exist_ok=True)
        outfile_path = os.path.join("${results_dir}", chunk_file)
        with open(outfile_path, "w") as write_file:
            for line in lines:
                uppercase_line = line.upper()
                write_file.write(uppercase_line)
                print(f"Uppercase chunk in file '{chunk_file}': {uppercase_line}")
    """  
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    ch_samplesheet = channel.fromPath('samplesheet_2.csv')
            .splitCsv(header: true)
            .view()
    
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    ch_chunk_files = SPLITLETTERS(ch_samplesheet).chunk_files

    
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
    outfiles = CONVERTTOUPPER(ch_chunk_files, 'results').outfiles
    outfiles.view { v -> "List with the paths of the chunk files: ${v}"}

    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    // TODO what?
    // convert the chunks to uppercase and save the files to the results directory



}