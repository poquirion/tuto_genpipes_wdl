import "genpipes_level_2.wdl" as readset_scatter



workflow wf {

  Array[Object] samples
  scatter(sample in samples) {
  # Scatter over reasdet
  call readset_scatter.l2_wf{input:sample=sample.name, readsets=sample.readsets}

  # Scatter over sample (gather readset to each sample too)
  # also this is F$!@#ed up I would have expected the input to
  # be  readset_scatter.l2_wf.out{1,2} but it is not :(
  call concat_readset_fastqs{input:sample=sample.name,
     pair1 = l2_wf.out1,
     pair2 = l2_wf.out2}

     # we could call a sub wf here and do a scatter over chr

  }

  # gather over sample
  call concat_sample_fastqs{ input:name='all_concatenated_sample',
     pair1 = concat_readset_fastqs.out1,
     pair2 = concat_readset_fastqs.out2 }


     output{
       File out1 = concat_sample_fastqs.out1
       File out2 = concat_sample_fastqs.out2
     }


}



task concat_readset_fastqs {
  # this take two list of files and concat them in two files
  Array[File] pair1
  Array[File] pair2
  String sample

  command<<<
    cat ${sep=" " pair1} > pair1_concateneted_readsets_for_${sample}.fastq
    cat ${sep=" " pair2} > pair2_concateneted_readsets_for_${sample}.fastq
  >>>
  output {
    File out1 = "pair1_concateneted_readsets_for_${sample}.fastq"
    File out2 = "pair2_concateneted_readsets_for_${sample}.fastq"
  }
}


task concat_sample_fastqs {
  # again but now take a list  sample fastq and put them in a single file
  Array[File] pair1
  Array[File] pair2
  String name
  command<<<
    cat ${sep=" " pair1} > ${name}_pair1.fastq
    cat ${sep=" " pair2} > ${name}_pair2.fastq
  >>>
  output {
    File out1 = "${name}_pair1.fastq"
    File out2 = "${name}_pair2.fastq"
  }
}
