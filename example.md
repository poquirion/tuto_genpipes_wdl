To run a fake pipeline, run

```
java -jar cromwell-XX.jar run uniq.json genpipes_level_1.wdl
```

The pipelines creates a pair of "fastq" files for every readset (it is just the name of the readset printed in a file that has a .fastq extension)


Then the readset files are concateneted into a par of file per sample 

and then the sample files are concateneted into a single pair of file that should includes the name of all the readsets. 

