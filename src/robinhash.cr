require "./testhash/*"

module TestHash
  EMPTY = UInt32::MAX

  class RobinHash(K, V)
    MAX_LOAD_FACTOR = 90
    MIN_LOAD_FACTOR = 25

    def initialize(*args)
      @used = 0
      @allocated = 3
      @data = Slice((UInt32 | {K, V})).new(1 << @allocated) { EMPTY.as((UInt32 | {K, V})) }
    end

    def []=(key, value)
      @used += 1
      rehash(@allocated + 1) if @used > MAX_LOAD_FACTOR*(1 << @allocated)/100
      index = lookup_robin(key, value)
    end

    def []?(key)
      index = lookup_search(key)
      return nil unless index = lookup_search(key)
      case x = @data[index]
      when UInt32
        return nil
      else
        return x[1]
      end
    end

    def delete(key, &block)
      @used -= 1
      return unless index = lookup_search(key)
      v = @data[index]
      unless v.is_a?(UInt32)
        @data[index] = dib(v[0].hash, index)
        rehash(@allocated - 1) if @allocated > 3 && @used < MIN_LOAD_FACTOR*(1 << @allocated)/100
      end
    end

    private def rehash(new_size)
      old = @data
      @allocated = new_size
      @data = Slice((UInt32 | {K, V})).new(1 << @allocated) { EMPTY.as((UInt32 | {K, V})) }
      @used = 0
      old.each do |x|
        self[x[0]] = x[1] unless x.is_a?(UInt32)
      end
    end

    @[AlwaysInline]
    def dib(hash, index)
      mask = (1 << @allocated) - 1
      UInt32.new(index - hash) & mask
    end

    @[AlwaysInline]
    private def lookup_search(key)
      mask = (1 << @allocated) - 1
      index = key & mask
      offset = 0
      loop do
        case v = @data[index]
        when UInt32
          return nil if (offset > v) || v == EMPTY
        else
          return index if v[0] == key
          return nil if dib(v[0].hash, index) > offset
        end
        index = (index + 1) & mask
        offset += 1
      end
    end

    @[AlwaysInline]
    private def lookup_robin(key, value)
      mask = (1 << @allocated) - 1
      offset = 0
      index = key & mask
      loop do
        v = @data[index]
        case v
        when UInt32
          if v > offset # including EMPTY
            @data[index] = {key, value}
            return
          end
        else
          if v[0] == key
            # override existing
            @data[index] = {key, value}
            return
          end
          old_offset = dib(v[0].hash, index)
          if old_offset < offset
            # steal from rich, give to poor
            @data[index] = {key, value}
            key = v[0]
            value = v[1]
            offset = old_offset
          end
        end
        index = (index + 1) & mask
        offset += 1
      end
    end
  end

  # TODO Put your code here
end
