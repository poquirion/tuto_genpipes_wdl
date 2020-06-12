task print {
  Object f
  command<<<

    echo I got name ${f.name} with sample ${f.sample}
  >>>
   output { String out = read_string(stdout()) }
}



workflow wf {
  Array[Object] readsets
  scatter(rs in readsets) {
    call print{input: f = rs}
  }


}
