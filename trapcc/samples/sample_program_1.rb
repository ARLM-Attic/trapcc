require_relative '../interrupt_program'
require_relative '../debug_program'
def counter_program
  p = Program.new()
  p.variable :reset, 20
  p.variable :evencounter, 10
  p.variable :oddcounter, 18
  p.instruction :dec_odd, :oddcounter, :evencounter, :dec_even , :reset, 0
  p.instruction :dec_even, :evencounter, :oddcounter, :dec_odd, :reset , 1
  p.instruction :reset, :evencounter, :reset, :dec_odd, :dec_even, 2 #This always takes the a branch
  p.start :dec_odd
  p
end

def exit_program
  p = Program.new()
  p.variable :reset, 20
  p.variable :evencounter, 8
  p.variable :oddcounter, 8
  p.instruction :dec_odd, :oddcounter, :evencounter, :dec_even , :exit, 0
  p.instruction :dec_even, :evencounter, :oddcounter, :dec_odd, :exit , 1
  p.start :dec_odd
  p

end
def subtract_program
  p = Program.new()
  p.variable :a, 40
  p.variable :b, 20
  p.instruction :dec_b,:b, :b, :dec_a, :done_1 ,1
  p.instruction  :dec_a, :a,:a ,:dec_b, :done_1, 2

  p.instruction :done_1, :tmp_var, :a, :done_2 , :done_2,3
  p.instruction :done_2, :tmp_var, :a , :done_1, :done_1,4
  p
end

class GameOfLifeProgram
  attr_accessor :size
  def initialize(programClass,size,init)
    @size = size
    @p = programClass.new()
    @p.variable :const_9, 9*4
    @p.variable :const_1, 4
    @p.variable :const_2, 2*4
    @p.variable :const_3, 3*4

    @p.variable :counter, 9*4
    @p.instruction :exit, :tmp_var,:counst_9 , 0x18, 0x18, 15
    next_inst = :exit
    cells = []
    (0..size-1).each do |x |
      (0..size-1).each do |y |
        @p.variable "NewCellX#{x}Y#{y}", 4096
        @p.variable "CellX#{x}Y#{y}", init[x][y] > 0 ? 4 : 0
        c = Cell.new(x,y,size)
        cells << c
        next_inst = c.copy_instructions(@p,next_inst)
      end
    end
    cells.each do |c|
      next_inst = c.step_instructions(@p,next_inst)
    end
    @p.start next_inst
  end

  def program
    @p
  end
  def source
    @p.encode
  end
  class Cell
    def name
      "X#{@x}Y#{@y}"
    end
    def initialize(x,y,size)
      @x,@y,@size = x,y,size
    end
    def dec_x_ifnot_y(label,p, x,y,nxt)  # 1 2
      s1 = "check #{label}"
      s2 = "dec #{label}"
      s3 = "noop out #{label}"
      p.instruction s1, :tmp_var, y, s3, s2 , 1  # Decrement if this was an underflow
      p.instruction s2, x, x, s3 , s3, 2
      p.instruction s3, :tmp_var, :const_9 , nxt,nxt , 3
      s1
    end
    def n(dx,dy)
      return "CellX#{(@x+dx)%@size}Y#{(@y+dy)%@size}"
    end
    def cellvar
      "Cell#{name}"
    end
    def cellnewvar
      "NewCell#{name}"
    end
    def copy_instructions(p,next_inst)
      p.instruction "copy#{name}", cellvar, cellnewvar, next_inst, next_inst
    end
    def step_instructions(p, next_inst)
      p.instruction "die#{name}", cellnewvar, :const_2 , next_inst , next_inst, 4
      p.instruction "live#{name}", cellnewvar, :const_3, next_inst,next_inst, 5
      p.instruction "maint#{name}", :tmp_var, cellvar, "live#{name}", "die#{name}", 6

      #Read this bottoms up
      tl,t,tr = n(-1,-1), n(-1,0), n(-1,1)
      l,r = n(-1,0), n(1,0)
      bl,b,br = n(1,-1), n(1,0), n(1,1)
      p.instruction "0-#{name}", :counter, :counter, "1-#{name}", "die#{name}",7   # 0 live cells
      p.instruction "1-#{name}", :counter, :counter, "2-#{name}", "die#{name}",8   # 1 live cell
      p.instruction "2-#{name}", :counter, :counter, "3-#{name}", "maint#{name}",9   # 2 live
      p.instruction "3-#{name}", :counter, :counter, "die-#{name}", "live#{name}",10   # 3 live cells
      #If less, you die
      # above here, :counter has the number of  live neighbours
      a= dec_x_ifnot_y("cdec TL #{name}",p,:counter,tl,"0-#{name}")
      a=dec_x_ifnot_y("cdec T #{name}",p,:counter,t,a)
      a=dec_x_ifnot_y("cdec TR #{name}",p,:counter,tr,a)
      a=dec_x_ifnot_y("cdec L #{name}",p,:counter,l,a)
      a=dec_x_ifnot_y("cdec R #{name}",p,:counter,r,a)
      a= dec_x_ifnot_y("cdec BR #{name}",p,:counter,br,a)
      a=dec_x_ifnot_y("cdec B #{name}",p,:counter,bl,a)
      a=dec_x_ifnot_y("cdec BL #{name}",p,:counter,b,a)
      p.instruction "#{name} init_ctr", :counter, :const_9, a,a, 0
      "#{name} init_ctr"
      #TODO: Add exit instruction
    end
  end
end

#print exit_program.encode
#debug_gol_program(GameOfLifeProgram.new(DebugProgram,4, [[1,1,1,1 ], [1,1,1,1], [1,1,1,1], [1,1,1,1]]))
debug_gol_program(GameOfLifeProgram.new(DebugProgram,2,[[1,1],[1,1]]))

