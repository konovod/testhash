require "./testhash/*"

module TestHash
  class RobinHash(K, V)
    MAX_LOAD_FACTOR = 50

    # @check = Hash(K, V).new

    # def sanity
    #   @check.values.sum == @data.sum { |x| x ? x[1] : 0 }
    # end

    def initialize(*args)
      @used = 0
      @allocated = 3
      @data = Slice({K, V}?).new(1 << @allocated) { nil.as({K, V}?) }
    end

    def []=(key, value)
      lookup_robin(key, value)
      # @check[key] = value
      # raise "" unless sanity
      rehash(@allocated + 1) if @used > MAX_LOAD_FACTOR*(1 << @allocated)/100
    end

    def []?(key)
      if index = lookup_search(key)
        @data[index].not_nil![1]
      else
        return nil
      end
    end

    def delete(key, &block)
      return unless index = lookup_search(key)
      v = @data[index]
      @used -= 1
      oldindex = index
      loop do
        oldindex = index
        index = (index + 1) & mask
        break unless v = @data[index]
        cur_offset = dib(v[0].hash, index)
        break if cur_offset == 0
        @data[oldindex] = @data[index]
      end
      @data[oldindex] = nil
      # @check.delete(key) { yield }
      # raise "" unless sanity
    end

    private def rehash(new_size)
      # @check.clear
      # p "#{new_size <= @allocated ? "shrink" : "growth"} #{new_size}"
      old = @data
      @allocated = new_size
      @data = Slice({K, V}?).new(1 << @allocated) { nil.as({K, V}?) }
      @used = 0
      old.each do |x|
        self[x[0]] = x[1] if x
      end
    end

    @[AlwaysInline]
    def mask
      (1 << @allocated) - 1
    end

    @[AlwaysInline]
    def dib(hash, index)
      UInt32.new(index - hash) & mask
    end

    @[AlwaysInline]
    private def lookup_search(key)
      index = key.hash & mask
      offset = 0
      loop do
        if v = @data[index]
          cur_offset = dib(v[0].hash, index)
          return nil if cur_offset < offset
          return index if cur_offset == offset && v[0] == key
          # if cur_offset < offset && @check[key]?
          #   p @data.map_with_index { |x, i| x ? [x[0].hash, i, dib(x[0].hash, i)] : nil }
          #   pp key, index, offset, cur_offset
          #   raise ""
          # end
        else
          # raise "" if @check[key]?
          return nil
        end
        index = (index + 1) & mask
        offset += 1
        # raise "NO" if offset > mask
      end
    end

    @[AlwaysInline]
    private def lookup_robin(key, value)
      offset = 0
      index = key.hash & mask
      loop do
        v = @data[index]
        unless v
          @used += 1
          @data[index] = {key, value}
          return
        end
        old_offset = dib(v[0].hash, index)
        if old_offset == offset && v[0] == key
          # override existing
          @data[index] = {key, value}
          return
        end
        if old_offset < offset
          # steal from rich, give to poor
          @data[index] = {key, value}
          key = v[0]
          value = v[1]
          offset = old_offset
        end
        index = (index + 1) & mask
        offset += 1
        # raise "NO" if offset > mask
      end
    end
  end

  # TODO Put your code here
end
