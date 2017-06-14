require "./testhash/*"

MAX_LOAD_FACTOR = 75

# MIN_LOAD_FACTOR = 25

module TestHash
  enum Status
    Empty
    Tombstone
  end

  class MyHash(K, V)
    def initialize(*args)
      @used = 0
      @allocated = 3
      @data = Slice((Status | {K, V})).new(1 << @allocated) { Status::Empty.as((Status | {K, V})) }
    end

    def []=(key, value)
      @used += 1
      rehash(@allocated + 1) if @used > MAX_LOAD_FACTOR*(1 << @allocated)/100
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
        # rehash(@data.size/2) if @data.size > 16 && @used < MIN_LOAD_FACTOR*@data.size/100
      end
    end

    private def rehash(new_size)
      old = @data
      @allocated = new_size
      @data = Slice((Status | {K, V})).new(1 << @allocated) { Status::Empty.as((Status | {K, V})) }
      @used = 0
      old.each do |x|
        self[x[0]] = x[1] unless x.is_a?(Status)
      end
    end

    @[AlwaysInline]
    private def lookup(key)
      mask = (1 << @allocated) - 1
      index = key & mask
      delta = 1
      loop do
        v = @data[index]
        return index if v.is_a?(Status)
        return index if v[0].hash == key.hash
        index = (index + delta*delta) & mask
        delta += 1
      end
    end
  end

  # TODO Put your code here
end
