require "./spec_helper"

def simple_tests(hsh)
  rnd = Random.new(1)
  it "first test" do
    hsh[0] = -1
    hsh[8] = -2
    hsh[16] = -3
    hsh.delete(8) { }
    hsh[16]?.should eq -3
    hsh[0]?.should eq -1
  end
  it "adding" do
    1000.times do |i|
      hsh[i] = i
    end
    1000.times do |i|
      hsh[i]?.should eq i
    end
  end
  it "deleting" do
    1000.times do |i|
      if i % 13 == 0
        hsh.delete(i) { }
      end
    end
    1000.times do |i|
      if i % 13 == 0
        hsh[i]?.should eq nil
      else
        hsh[i]?.should eq i
      end
    end
  end
end

def test_random(hsh, iter, n)
  base = Hash(Int32, Int32).new
  iter.times do |i|
    rnd = Random.new(i)
    # addition
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      base[v] = i
      hsh[v] = i
    end
    # deleting
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      base.delete(v) { }
      hsh.delete(v) { }
    end
    # lookup after changes
    rnd.rand(n/2).times do |i|
      v = rnd.rand(n)
      if hsh[v]? != base[v]?
        pp v, base[v]?, hsh[v]?
        raise ""
      end
    end
  end
end

def test_string(hsh)
  hsh["1"] = "2"
  hsh["2"] = "1"
  raise "" if hsh[hsh["1"]?]? != "1"
  raise "" if hsh[hsh["2"]?]? != "2"
end

describe "MyHash" do
  it "works with strings" do
    test_string TestHash::MyHash(String, String).new
  end
  simple_tests TestHash::MyHash(Int32, Int32).new
  it "passes observable random test" do
    test_random TestHash::MyHash(Int32, Int32).new, 300, 10
  end
  it "passes random test" do
    test_random TestHash::MyHash(Int32, Int32).new, 30, 10000
  end
end

describe "RobinHash" do
  it "works with strings" do
    test_string TestHash::RobinHash(String, String).new
  end
  simple_tests TestHash::RobinHash(Int32, Int32).new
  it "passes observable random test" do
    test_random TestHash::RobinHash(Int32, Int32).new, 300, 10
  end
  it "passes random test" do
    test_random TestHash::RobinHash(Int32, Int32).new, 30, 10000
  end
end
