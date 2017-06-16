# testhash

```
[andrew@lenovo testhash]$ crystal bench.cr --release
default  32.64k ( 30.64µs) (±15.04%)  1.10× slower
     my  34.18k ( 29.25µs) (±19.72%)  1.05× slower
  robin  35.99k ( 27.79µs) (±16.26%)       fastest
default avg  15.01k ( 66.64µs) (±12.28%)       fastest
     my avg  14.24k ( 70.23µs) (±14.42%)  1.05× slower
  robin avg  14.31k (  69.9µs) (±15.99%)  1.05× slower
GC Warning: Repeated allocation of very large block (appr. size 36864):
	May lead to memory leak and poor performance
...
GC Warning: Repeated allocation of very large block (appr. size 36864):
	May lead to memory leak and poor performance
default big 369.95  (   2.7ms) (±16.68%)  1.31× slower
     my big 459.17  (  2.18ms) (± 1.74%)  1.06× slower
  robin big 485.28  (  2.06ms) (± 2.90%)       fastest
-108523014
[andrew@lenovo testhash]$
```
