require "./src/testhash"
require "./src/robinhash"
require "../crystal-hash/src/crystal-hash"
require "../prngs/src/prngs"
require "benchmark"

alias Key = Int32

CLASSES =
  [
    Hash(Key, Int32),
    # Hash2b(Key, Int32),
    # TestHash::Overhead(Key, Int32),
    # TestHash::MyHash(Key, Int32),
    TestHash::RobinHash(Key, Int32),
  ]
LOOKUP_MULT = 10

def the_test(cls, scenario)
  rng = Random::PCG32.new(1)
  initial = scenario[:initial]
  delete_found = scenario[:delete_found]
  delete_notfound = scenario[:delete_notfound]
  inserts = scenario[:inserts]
  lookup_found = scenario[:lookup_found]
  lookup_notfound = scenario[:lookup_notfound]
  table = cls.new
  initial.times do |i|
    table[rng.next_u.to_i] = 1
  end
  rng.jump(-delete_found)
  delete_found.times do |i|
    table.delete(rng.next_u.to_i) { }
  end
  delete_notfound.times do |i|
    table.delete(rng.next_u.to_i) { }
  end
  rng.jump(-delete_notfound - delete_found)
  inserts.times do |i|
    table[rng.next_u.to_i] = 1
  end
  rng.jump(-lookup_found)
  sum = 0
  LOOKUP_MULT.times do
    (lookup_found + lookup_notfound).times do |i|
      sum += table[rng.next_u.to_i]? || 0
    end
    rng.jump(-lookup_found - lookup_notfound)
  end
end

def do_bench(text, scenario)
  puts "-----------#{text}------------"
  Benchmark.ips do |bench|
    CLASSES.each do |cls|
      bench.report "#{cls}" do
        the_test(cls, scenario)
      end
    end
  end
end

def all_tests(n)
  do_bench "setup #{n}", {initial: n, delete_found: 0, delete_notfound: 0, inserts: 0, lookup_found: 0, lookup_notfound: 0}
  #  do_bench "lookup_found #{n}", {initial: n, delete_found: 0, delete_notfound: 0, inserts: 0, lookup_found: n, lookup_notfound: 0}
  #  do_bench "lookup_notfound #{n}", {initial: n, delete_found: 0, delete_notfound: 0, inserts: 0, lookup_found: 0, lookup_notfound: n}
  #  do_bench "delete_found #{n}", {initial: n, delete_found: n, delete_notfound: 0, inserts: 0, lookup_found: 0, lookup_notfound: 0}
  #  do_bench "delete_notfound #{n}", {initial: n, delete_found: 0, delete_notfound: n, inserts: 0, lookup_found: 0, lookup_notfound: 0}
  #  do_bench "inserts #{n}", {initial: n, delete_found: n/2, delete_notfound: 0, inserts: n/2, lookup_found: 0, lookup_notfound: 0}
  do_bench "full #{n}", {initial: n, delete_found: n/2, delete_notfound: n/2, inserts: n/2, lookup_found: n, lookup_notfound: n}
end

all_tests 10
all_tests 125
all_tests 1000
