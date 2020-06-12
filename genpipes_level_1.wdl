import "genpipes_level_2.wdl" as readset_scatter



workflow wf {

  Array[Object] samples
  scatter(sample in samples) {
  # maybe it should be sample.name, we could also add a
  # sample name under reasset.sample
  call readset_scatter.wf{input:sample=sample.sample, readsets=sample.readsets}

  }
}
