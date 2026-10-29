$F = [
  [0,   'F', 'F'],
  ['F', 'F',  0],
  [0,   'F',  0],
]

$I = [
  [ 'I' ],
  [ 'I' ],
  [ 'I' ],
  [ 'I' ],
  [ 'I' ],
]

$L = [
  ['L',  0 ],
  ['L',  0 ],
  ['L',  0 ],
  ['L', 'L'],
]

$N = [
  [0, 'N'],
  ['N', 'N'],
  ['N', 0],
  ['N', 0]
]

$P = [
  ["P", "P"],
  ["P", "P"],
  ["P", 0]
]

$T = [
  ['T', 'T', 'T'],
  [0,   'T',   0],
  [0,   'T',   0],
]

$U = [
  ['U',  0, 'U'],
  ['U', 'U', 'U']
]

$V = [ 
  ['V', 0, 0],
  ['V', 0, 0],
  ['V', 'V', 'V'],
]

$W = [
  ['W',  0,   0],
  ['W', 'W',  0],
  [0,   'W', 'W']
]

$X = [
  [ 0,  'X',  0 ],
  ['X', 'X', 'X'],
  [ 0,  'X',  0 ]
]

$Y = [
  [0,   'Y'],
  ['Y', 'Y'],
  [0,   'Y'],
  [0,   'Y']
]

$Z = [
  ['Z', 'Z',  0 ],
  [ 0 , 'Z',  0 ],
  [ 0 , 'Z', 'Z']
]

class Pentamino  
    attr_reader :name, :email 
    attr_reader :arrangement 

    def initialize (arrangement)
        @arrangement = arrangement.dup
    end

    def to_s
        puts @arrangement.class
        s = ""
        for row in @arrangement do
            for col in row do
                s += "#{col} "
            end
            s += "\n"
        end

        s
    end   

    def rotate
        rotated = @arrangement.transpose.map(&:reverse)
        return Pentamino.new(rotated)
    end


    def [](i)
        return @arrangement[i]
    end

    def length
        return @arrangement.length
    end

    def ==(other)
        if other.class != Pentamino
            return false
        end

        return @arrangement == other.arrangement
    end


    alias size length
end


class Grid

    attr_reader :grid

    def initialize(rows=nil, cols=nil, grid=nil)
        if rows && cols then
            unless rows > 0 && cols > 0 
                raise IndexError, "rows and cols must be > 0"
            end
            @grid = Array.new(rows) { Array.new(cols, 0) }
        end
        if grid
            @grid = grid.map(&:dup)
        end
    end

    def to_s
        s = ""
        for row in @grid do
          for i in row do
            s += "#{ i } "
          end
          s += "\n"
        end

        return s
    end
    

    def valid_placement? (i, j, p)
      # i, j represent the topleft corner of the pentamino p
      
      for r in 0...p.arrangement.length do
      
        if @grid[i+r].nil? then
          puts "grid is out bounds on row"
          return false
        end
        
        for c in 0...p.arrangement[r].length do
          
          if p[r][c] == 0 then
            next        
          
          elsif (@grid[i+r][j+c].nil? || @grid[i+r][j+c] != 0) then
            puts "nil? #{@grid[i+r][j+c].nil?}"
            
            return false
          end

        end

      end

      return true
    end

    def apply(i,j,p)
        unless valid_placement?(i,j,p)
            raise IndexError, "Invalid placement for #{p}, #{i}, #{j}"
        end

        grid = @grid.map(&:dup)

        for r in 0...p.length
            for c in 0...p[r].length
                if p.arrangement[r][c] != 0 then
                    grid[i + r][j+c] = p.arrangement[r][c]
                end
            end
        end

        return Grid.new(nil, nil, grid)
    end


    def solved?
        for row in @grid do
            for ele in row do
                if ele == 0 then
                    return false
                end
            end
        end

        return True
    end

    

    def solve(used)
        # solve
        for i in 0...@grid.length do
            for j in 0...@grid[i].length do
                for pentamino in $Pentaminos.select { |p| (p in used) } do
                    4.times do
                        p = pentamino.rotate
                        
                        grid = apply(i,j,p) 
                        
                        puts "applied pentamino #{p} to grid: \n#{grid}"
                        
                        used << pentamino

                        if solved? then
                            return grid
                        end
                        
                        grid.solve( used )
                    end
                end
            end
        end
        
        return false
    end

    def ==(other)
        if other.class != Grid then
            false
        end
        
        @grid == other
    end

end


$Pentaminos = [
  Pentamino.new($F),
  Pentamino.new($I),
  Pentamino.new($L),
  Pentamino.new($N),
  Pentamino.new($P),
  Pentamino.new($T),
  Pentamino.new($U),
  Pentamino.new($V),
  Pentamino.new($W),
  Pentamino.new($X),
  Pentamino.new($Y),
  Pentamino.new($Z)
]


if __FILE__ == $0
    rows, cols = 5,5
    grid = Grid.new(rows.to_i, cols.to_i)
    p grid.solve([])

end


=begin

solver:
    for each cell:
        for each pentamino:
            for each rotation
                solve appliedgrid  - recurse with used

=end

