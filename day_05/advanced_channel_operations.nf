params {
    step: Integer = 0
    files_dir_path: String = "/home/markus/MasterVault/Semester 2/biomedical_data/computational-workflows-2026/day_05/files_dir"
}


workflow{

    // Task 1 - Read in the samplesheet.

    if (params.step == 1) {
        samplesheet = channel.fromPath('samplesheet.csv')
            .splitCsv(header: true)
            .view()

    }

    // Task 2 - Read in the samplesheet and create a meta-map with all metadata and another list with the filenames ([[metadata_1 : metadata_1, ...], [fastq_1, fastq_2]]).
    //          Set the output to a new channel "in_ch" and view the channel. YOU WILL NEED TO COPY AND PASTE THIS CODE INTO SOME OF THE FOLLOWING TASKS (sorry for that).

    if (params.step == 2) {
        // TODO filenames -> filepaths
        samplesheet_map = channel.fromPath('samplesheet.csv').splitCsv(header: true)
        in_ch = samplesheet_map.map{row -> [["id":row.sample, "strandedness":row.strandedness], ["${params.files_dir_path}/${row.fastq_1}", "${params.files_dir_path}/${row.fastq_2}"]]}
        in_ch.view()
    }

    // Task 3 - Now we assume that we want to handle different "strandedness" values differently. 
    //          Split the channel into the right amount of channels and write them all to stdout so that we can understand which is which.

    if (params.step == 3) {
        samplesheet_map = channel.fromPath('samplesheet.csv').splitCsv(header: true)
        in_ch = samplesheet_map.map{row -> [["id":row.sample, "strandedness":row.strandedness], ["${params.files_dir_path}/${row.fastq_1}", "${params.files_dir_path}/${row.fastq_2}"]]}
        in_ch.branch{v -> 
            auto: v[0]["strandedness"] == "auto"
            forward: v[0]["strandedness"] == "forward"
            reverse: v[0]["strandedness"] == "reverse"
        }.set { result}
        result.auto.view { v -> "strandedness=auto: $v"}
        result.forward.view { v -> "strandedness=forward: $v"}
        result.reverse.view { v -> "strandedness=reverse: $v"}
    }

    // Task 4 - Group together all files with the same sample-id and strandedness value.

    if (params.step == 4) {
        samplesheet_map = channel.fromPath('samplesheet.csv').splitCsv(header: true)
        in_ch = samplesheet_map.map{row -> [["id":row.sample, "strandedness":row.strandedness], ["${params.files_dir_path}/${row.fastq_1}", "${params.files_dir_path}/${row.fastq_2}"]]}
        in_ch.groupTuple(by: 0).view()
    }



}