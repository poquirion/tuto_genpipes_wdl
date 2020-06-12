import "scatter_readsets.wdl" as rs_scatter

task print {
  Object f
  command<<<

    echo I got sample ${f.sample}
  >>>
   output { String out = read_string(stdout()) }
}


workflow wf {
  Array[Object] samples
  scatter(s in samples) {

    call print{input: f = s}

    call rs_scatter.wf{input: readsets = s.readsets }
  }
}
