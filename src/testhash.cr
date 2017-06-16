require "./testhash/*"

module TestHash
  enum Status
    Empty
    Tombstone
  end

  class MyHash(K, V)
    MAX_LOAD_FACTOR = 50
    MAX_TOMB_FACTOR = 80

    def initialize(*args)
      @used = 0
      @tombs = 0
      @allocated = 3
      @data = Slice((Status | {K, V})).new(1 << @allocated) { Status::Empty.as((Status | {K, V})) }
    end

    def []=(key, value)
      index = lookup(key, false)
      @used += 1 if @data[index].is_a? Status
      @data[index] = {key, value}
      rehash(@allocated + 1) if @used + @tombs > MAX_LOAD_FACTOR*(1 << @allocated)/100
    end

    def []?(key)
      index = lookup(key, true)
      case x = @data[index]
      when Status
        return nil
      else
        return x[1]
      end
    end

    def delete(key, &block)
      index = lookup(key, true)
      if @data[index].is_a?(Status)
        yield
      else
        @used -= 1
        @tombs += 1
        @data[index] = Status::Tombstone
        rehash(@allocated) if @tombs > MAX_TOMB_FACTOR*(@used + @tombs) / 100
      end
    end

    private def rehash(new_size)
      old = @data
      @allocated = new_size
      @data = Slice((Status | {K, V})).new(1 << @allocated) { Status::Empty.as((Status | {K, V})) }
      @used = 0
      @tombs = 0
      old.each do |x|
        self[x[0]] = x[1] unless x.is_a?(Status)
      end
    end

    @[AlwaysInline]
    def mask
      (1 << @allocated) - 1
    end

    @[AlwaysInline]
    private def lookup(key, search)
      index = key.hash & mask
      delta = 1
      loop do
        case v = @data[index]
        when Status
          return index if v == Status::Empty
        else
          return index if v[0] == key
        end
        index = (index + delta*delta) & mask
        delta += 1
      end
    end
  end

  class Overhead(K, V)
    @somek : K?
    @somev : V?

    def initialize(*args)
    end

    def []=(key, value)
      @somek = key
      @somev = value
    end

    def []?(key)
      return @somev
    end

    def delete(key, &block)
      @somek = key
      yield
    end
  end
end
