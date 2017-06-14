require "./testhash/*"

MAX_LOAD_FACTOR = 75
MIN_LOAD_FACTOR = 25

module TestHash
  enum Status
    Empty
    Tombstone
  end

  class MyHash(K, V)
    @data = [] of (Status | {K, V})
    @used = 0

    def initialize(*args)
      @data = Array((Status | {K, V})).new(16, Status::Empty)
    end

    def []=(key, value)
      @used += 1
      rehash(@data.size*2) if @used > MAX_LOAD_FACTOR*@data.size/100
      index = lookup(key)
      @data[index] = {key, value}
    end

    def []?(key)
      index = lookup(key)
      case x = @data[index]
      when Status
        return nil
      else
        return x[1]
      end
    end

    def delete(key, &block)
      @used -= 1
      index = lookup(key)
      unless @data[index].is_a?(Status)
        @data[index] = Status::Tombstone
        rehash(@data.size/2) if @data.size > 16 && @used < MIN_LOAD_FACTOR*@data.size/100
      end
    end

    private def rehash(new_size)
      old = @data
      @data = Array((Status | {K, V})).new(new_size, Status::Empty)
      @used = 0
      old.each do |x|
        self[x[0]] = x[1] unless x.is_a?(Status)
      end
    end

    private def lookup(key)
      index = key % @data.size
      delta = 1
      loop do
        v = @data[index]
        return index if v.is_a?(Status)
        return index if v[0].hash == key.hash
        index = (index + delta*delta) % @data.size
        delta += 1
      end
    end
  end

  # TODO Put your code here
end
