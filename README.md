# testhash

```
[andrew@lenovo testhash]$ crystal bench.cr --release
-----------setup 10------------
               Hash(Int32, Int32) 663.61k (  1.51µs) (±20.05%)  1.19× slower
TestHash::RobinHash(Int32, Int32) 788.06k (  1.27µs) (±21.55%)       fastest
-----------full 10------------
               Hash(Int32, Int32) 126.62k (   7.9µs) (±16.07%)  1.18× slower
TestHash::RobinHash(Int32, Int32) 149.83k (  6.67µs) (±17.48%)       fastest
-----------setup 125------------
               Hash(Int32, Int32)  44.97k ( 22.24µs) (±18.41%)       fastest
TestHash::RobinHash(Int32, Int32)   33.5k ( 29.85µs) (±11.42%)  1.34× slower
-----------full 125------------
               Hash(Int32, Int32)    7.7k (129.92µs) (±14.26%)  1.41× slower
TestHash::RobinHash(Int32, Int32)  10.86k (  92.1µs) (±15.89%)       fastest
-----------setup 1000------------
               Hash(Int32, Int32)   5.32k (187.89µs) (±12.51%)       fastest
TestHash::RobinHash(Int32, Int32)   4.86k (205.58µs) (±15.93%)  1.09× slower
-----------full 1000------------
               Hash(Int32, Int32)  948.4  (  1.05ms) (±16.21%)  1.39× slower
TestHash::RobinHash(Int32, Int32)   1.32k (759.96µs) (±14.79%)       fastest
```
