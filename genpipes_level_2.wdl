task picard_sam_to_fastq {
  Object readset
  command<<<
    cat << EOF
    module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.9.0 && \
    java -Djava.io.tmpdir=$TMPDIR -XX:+UseParallelGC \
    -XX:ParallelGCThreads=1 -Dsamjdk.buffer_size=4194304 -Xmx18G -jar \
    $PICARD_HOME/picard.jar SamToFastq \
    VALIDATION_STRINGENCY=LENIENT \
    INPUT=~{readset.bam} \
    FASTQ=~{readset.name}_pair1.fatsq.gz \
    SECOND_END_FASTQ=~{readset.name}_pair2.fastq.gz
    EOF
    # fake pipeline !
    touch ~{readset.name}_pair1.fatsq.gz
    touch ~{readset.name}_pair2.fastq.gz
  >>>
  output {
    File out1 = "${readset.name}_pair1.fatsq.gz"
    File out2 = "${readset.name}_pair2.fastq.gz"
  }
}
task sym_link_fastq {
  Object readset
  String sample
  String in1
  String in2
  command<<<
    cat << EOF
    mkdir -p deliverables/~{sample.name}/wgs/raw_reads && \
    ln -sf \
    ~{in1} \
    deliverables/~{sample}/wgs/raw_reads/~{readset.name}.pair1.fastq.gz && \
    mkdir -p deliverables/~{sample}/wgs/raw_reads && \
    ln -sf \
    ~{in2} \
    deliverables/~{sample}/wgs/raw_reads/~{readset.name}.pair2.fastq.gz
    EOF
    # fake pipeline !
    mkdir -p deliverables/${sample}/wgs/raw_reads/
    touch deliverables/~{sample}/wgs/raw_reads/~{readset.name}.pair1.fastq.gz
    touch deliverables/~{sample}/wgs/raw_reads/~{readset.name}.pair2.fastq.gz
  >>>
  output {
    File out1 = "deliverables/${sample}/wgs/raw_reads/${readset.name}.pair1.fastq.gz"
    File out2 = "deliverables/${sample}/wgs/raw_reads/${readset.name}.pair2.fastq.gz"
  }
}
workflow wf {
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

  }




}
