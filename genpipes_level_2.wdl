task picard_sam_to_fastq {
  Object readset
  String CPU = "1"
  String RAM = "1G"
  command<<<
    # note that cromwell knows about runtime and will use these entry to select the right machine
    cat << EOF
    module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.9.0 && \
    java -Djava.io.tmpdir=$TMPDIR -XX:+UseParallelGC \
    -XX:ParallelGCThreads=${CPU} -Dsamjdk.buffer_size=4194304 -Xmx${RAM} -jar \
    $PICARD_HOME/picard.jar SamToFastq \
    VALIDATION_STRINGENCY=LENIENT \
    INPUT=${readset.bam} \
    FASTQ=${readset.name}_pair1.fatsq.gz \
    SECOND_END_FASTQ=${readset.name}_pair2.fastq.gz
    EOF
    # fake pipeline !
    echo I am some fake fastq ${readset.name} > ${readset.name}_pair1.fatsq
    echo I am some fake fastq ${readset.name} > ${readset.name}_pair2.fastq
  >>>
  output {
    File out1 = "${readset.name}_pair1.fatsq"
    File out2 = "${readset.name}_pair2.fastq"
  }
}
task sym_link_fastq {
  Object readset
  String sample
  String in1
  String in2
  command<<<
        mkdir -p deliverables/${sample}/wgs/raw_reads && \
    ln -sf \
    ${in1} \
    deliverables/${sample}/wgs/raw_reads/${readset.name}.pair1.fastq.gz && \
    mkdir -p deliverables/${sample}/wgs/raw_reads && \
    ln -sf \
    ${in2} \
    deliverables/${sample}/wgs/raw_reads/${readset.name}.pair2.fastq.gz
    >>>
  output {
    File out1 = "deliverables/${sample}/wgs/raw_reads/${readset.name}.pair1.fastq.gz"
    File out2 = "deliverables/${sample}/wgs/raw_reads/${readset.name}.pair2.fastq.gz"
  }
}
workflow l2_wf {
  String sample
  Array[Object] readsets

  scatter(readset in readsets) {

    call picard_sam_to_fastq{input: readset=readset}
    call sym_link_fastq{
      input:
        readset=readset, sample=sample,
        in1=picard_sam_to_fastq.out1,
        in2=picard_sam_to_fastq.out2
    }

    # to be passed to the main wf
    output{
      Array[File] out1 = picard_sam_to_fastq.out1
      Array[File] out2 = picard_sam_to_fastq.out2
    }

  }




}
