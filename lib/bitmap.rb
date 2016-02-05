class Bitmap
  attr_reader :width, :height

  def self.[](*args, **kwargs)
    Bitmap.new(*args, **kwargs)
  end

  def initialize(*args, &block)
    @width, @height = convert_args(*args)
    @bitset = Bitset.new(width * height)

    if block_given?
      self.each do |b, x, y, ix|
        yield self, x, y
      end
    end
  end

  def from_s(bitset_str)
    raise IndexError unless (width * height) == bitset_str.length
    @bitset= Bitset.from_s(bitset_str)
    self
  end

  def cardinality
    @bitset.cardinality
  end

  def to_s
    @bitset.
      each_with_index.
      each_with_object(String.new) do |(bit, ix), str|
      str << (bit ? "#" : ".")
      str << "\n" if ((ix + 1) % width) == 0
    end
  end

  def size
    @size ||= Size[@width, @height]
  end

  def |(other)
    bm = Bitmap.new(size)
    other_bs = other.instance_variable_get(:@bitset)
    bm.instance_variable_set(:@bitset, (@bitset | other_bs))
    bm
  end

  def &(other)
    bm = Bitmap.new(size)
    other_bs = other.instance_variable_get(:@bitset)
    bm.instance_variable_set(:@bitset, (@bitset & other_bs))
    bm
  end

  def ~
    bm = Bitmap.new(size)
    bm.instance_variable_set(:@bitset, ~@bitset)
    bm
  end

  def in_bounds?(*args)
    x,y= convert_args(*args)
    (x >= 0) && (x < width) &&
    (y >= 0) && (y < height)
  end
 
  def set(*args)
    self[*args]= true
  end

  def clear(*args)
    self[*args]= false
  end


  def edge?(*args)
    x,y= convert_args(*args)
    (x == 0) || (x == width - 1) ||
    (y == 0) || (y == height - 1)
  end

  def [](*args)
    @bitset[to_index(*args)]
  end

  def []=(*args, val)
    @bitset[to_index(*args)]= val
  end

  def each(&block)
    if block_given?
      @bitset.each_with_index do |b, ix|
        yield b, (ix % width), (ix.div(width)), ix
      end
    else
      return to_enum(__method__) { @bitset.size }
    end
  end

  def neighbors_of(*args)
    x,y = convert_args(*args)

    left_edge   = (x == 0)
    right_edge  = (x == width-1)
    top_edge    = (y == 0)
    bottom_edge = (y == height-1)

    bs = Bitmap[3,3]

    bs[1,0]= (top_edge)    || self[x,   y-1]
    bs[0,1]= (left_edge)   || self[x-1, y]
    bs[2,1]= (right_edge)  || self[x+1, y]
    bs[1,2]= (bottom_edge) || self[x,   y+1]

    bs[0,0]= (top_edge || left_edge)      || self[x-1, y-1]
    bs[2,0]= (top_edge || right_edge)     || self[x+1, y-1]
    bs[0,2]= (bottom_edge || left_edge)   || self[x-1, y+1]
    bs[2,2]= (bottom_edge || right_edge)  || self[x+1, y+1]
    bs
  end

  private
    def convert_args(a, *rest)
      case a
      when Vector then [a.x, a.y]
      when Hash   then [a[:x], a[:y]]
      else 
        [a, *rest]
      end
    end

    def to_index(*args)
      unless in_bounds?(*args)
        x,y= convert_args(*args)
        raise IndexError.new("Provided index [#{x},#{y}] is not within [0,0] <= index < [#{width},#{height}]")
      end
      x,y = convert_args(*args)

      (y * width) + x
    end
end
