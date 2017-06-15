require "./src/testhash"
require "./src/robinhash"
require "benchmark"

def try(hsh, n)
  rnd = Random.new(2)
  sum = 0i64
  # addition
  (1..n).each do |i|
    hsh[rnd.rand(n)] = i*i
  end
  # lookup before changes
  (1..n).each do |i|
    sum += hsh[rnd.rand(n)]? || 0
  end
  # deleting
  (1..n/2).each do |i|
    hsh.delete(rnd.rand(n)) { }
  end
  # readding
  (1..n).each do |i|
    hsh[rnd.rand(n)] = i*i
  end
  sum = 0
  # lookup after changes
  (1..n).each do |i|
    sum -= hsh[rnd.rand(n)]? || 0
  end
  sum
end

def try2(hsh1, hsh2, iter, n)
  sum1 = sum2 = 0
  iter.times do |i|
    rnd = Random.new(i)
    # addition
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      hsh1[v] = i*i
      hsh2[v] = i*i
    end
    # deleting
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      hsh1.delete(v) { }
      hsh2.delete(v) { }
    end
    # lookup after changes
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      sum1 += hsh1[v]? || 0
      sum2 += hsh2[v]? || 0
      if sum1 != sum2
        pp v, hsh1[v]?, hsh2[v]?
        raise ""
      end
    end
  end
end

try2(Hash(Int32, Int32).new(nil), TestHash::MyHash(Int32, Int32).new(nil), 30, 10000)
# try2(Hash(Int32, Int32).new(nil), TestHash::RobinHash(Int32, Int32).new(nil), 30, 10000)
# p try2(TestHash::RobinHash(Int32, Int32).new(nil), 100, 100)
#
x = 0
Benchmark.ips do |bench|
  bench.report("default") { x += try(Hash(Int32, Int32).new(nil), 10) }
  bench.report("my") { x += try(TestHash::MyHash(Int32, Int32).new(nil), 10) }
  # bench.report("robin") { x += try(TestHash::RobinHash(Int32, Int32).new(nil), 10) }
end
Benchmark.ips do |bench|
  bench.report("default avg") { x += try(Hash(Int32, Int32).new(nil), 125) }
  bench.report("my avg") { x += try(TestHash::MyHash(Int32, Int32).new(nil), 125) }
  # bench.report("robin avg") { x += try(TestHash::RobinHash(Int32, Int32).new(nil), 125) }
end
Benchmark.ips do |bench|
  bench.report("default big") { x += try(Hash(Int32, Int32).new(nil), 10000) }
  bench.report("my big") { x += try(TestHash::MyHash(Int32, Int32).new(nil), 10000) }
  # bench.report("robin big") { x += try(TestHash::RobinHash(Int32, Int32).new(nil), 10000) }
end
p x
