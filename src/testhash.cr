require "./testhash/*"

module TestHash
  enum Status
    Empty
    Tombstone
  end

  class MyHash(K, V)
    MAX_LOAD_FACTOR = 75
    MIN_LOAD_FACTOR =  5

    # @check = Hash(K, V).new

    def initialize(*args)
      @used = 0
      @tombs = 0
      @allocated = 3
      @data = Slice((Status | {K, V})).new(1 << @allocated) { Status::Empty.as((Status | {K, V})) }
    end

    # def sanity
    #   @check.values.sum == @data.sum { |x| x.is_a?(Status) ? 0 : x[1] }
    # end

    def []=(key, value)
      index = lookup(key, false)
      @used += 1 if @data[index].is_a? Status

      # if index > 2 && index < @data.size - 5
      #   copy = @data[index - 2, 5].map &.inspect
      #   xxx = @check[key]?
      #   yyy = self[key]?
      #   oldsum = @check.values.sum
      # end

      @data[index] = {key, value}

      # @check[key] = value
      # unless sanity
      #   pp xxx, yyy, oldsum, @check.values.sum
      #   pp @data.sum { |x| x.is_a?(Status) ? 0 : x[1] }
      #   pp copy, @data[index - 2, 5], index, key, value
      #   raise ""
      # end

      rehash(@allocated + 1) if @used + @tombs > MAX_LOAD_FACTOR*(1 << @allocated)/100
    end

    def []?(key)
      index = lookup(key, true)
      case x = @data[index]
      when Status
        # raise "" if @check[key]?
        return nil
      else
        # raise "" if @check[key]? != x[1]
        return x[1]
      end
    end

    def delete(key, &block)
      index = lookup(key, true)
      # @check.delete(key) { yield }
      if @data[index].is_a?(Status)
        yield
      else
        @used -= 1
        @tombs += 1
        @data[index] = Status::Tombstone
        rehash(@allocated - 1) if @allocated > 3 && @used < MIN_LOAD_FACTOR*(1 << @allocated)/100
      end
    end

    private def rehash(new_size)
      # p "rehash #{new_size}"
      # @check.clear
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
    private def lookup(key, search)
      mask = (1 << @allocated) - 1
      index = key & mask
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
        # raise "#{inspect}" if delta > mask
      end
    end
  end

  # TODO Put your code here
end
