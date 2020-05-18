require "../array/array"

struct NumInternal::AxisIter(T)
  include Iterator(T)
  @shape : Array(Int32)
  @strides : Array(Int32)
  @inc : Int32
  @ptr : Pointer(T)
  @tmp : AnyArray(T)
  @total : Int32
  @yielded : Int32 = 0
  @axis : Int32

  def initialize(arr : AnyArray(T), @axis : Int32 = -1, keepdims = false)
    if @axis < 0
      @axis += arr.ndims
    end
    unless @axis < arr.ndims
      raise NumInternal::AxisError.new("Axis out of range for array")
    end

    @shape = arr.shape.dup
    @strides = arr.strides.dup
    @ptr = arr.to_unsafe
    @inc = arr.strides[axis]

    if keepdims
      @shape[axis] = 1
      @strides[axis] = 0
    else
      @shape.delete_at(axis)
      @strides.delete_at(axis)
    end

    @tmp = arr.class.new(@ptr, @shape, @strides)

    @total = arr.shape[axis]
  end

  def next
    if @yielded >= @total
      stop
    else
      ret = @tmp
      @yielded += 1
      @ptr += @inc
      @tmp = Tensor.new(@ptr, @shape, @strides)
      ret
    end
  end
end

struct NumInternal::UnsafeAxisIter(T)
  include Iterator(T)
  @shape : Array(Int32)
  @strides : Array(Int32)
  @inc : Int32
  @ptr : Pointer(T)
  @tmp : AnyArray(T)
  @axis : Int32

  def initialize(arr : AnyArray(T), @axis : Int32 = -1, keepdims = false)
    if @axis < 0
      @axis += arr.ndims
    end
    unless @axis < arr.ndims
      raise NumInternal::AxisError.new("Axis out of range for array")
    end

    @shape = arr.shape.dup
    @strides = arr.strides.dup
    @ptr = arr.to_unsafe
    @inc = arr.strides[axis]

    if keepdims
      @shape[axis] = 1
      @strides[axis] = 0
    else
      @shape.delete_at(axis)
      @strides.delete_at(axis)
    end
    @tmp = arr.class.new(@ptr, @shape, @strides)
  end

  def next
    ret = @tmp
    @ptr += @inc
    @tmp = Tensor.new(@ptr, @shape, @strides)
    ret
  end
end
