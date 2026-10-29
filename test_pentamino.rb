require "minitest/autorun"
require_relative "pentamino"

class TestGrid < Minitest::Test
    # setup
    def setup 
        @grid = Grid.new(5, 5)
    end
  

    def test_apply_L
        new_grid = @grid.apply( 1, 1, Pentamino.new($L) )

        assert_equal new_grid, [
        [0, 0,    0, 0, 0],
        [0, 'L',  0, 0, 0],
        [0, 'L',  0, 0, 0],
        [0, 'L',  0, 0, 0],
        [0, 'L', 'L',0, 0]
        ]
    end

    def test_multi_apply
        new_grid = @grid.apply(1,1, Pentamino.new($L))
        new_grid = new_grid.apply(0,0, Pentamino.new($I))

        assert_equal new_grid.grid, [
            ['I', 0,    0, 0, 0],
            ['I', 'L',  0, 0, 0],
            ['I', 'L',  0, 0, 0],
            ['I', 'L',  0, 0, 0],
            ['I', 'L', 'L',0, 0]
        ]
    end

    def test_apply_I
        new_grid = @grid.apply(0,0, Pentamino.new($I))

        assert_equal new_grid.grid, [
        ['I', 0,  0, 0, 0],
        ['I', 0,  0, 0, 0],
        ['I', 0,  0, 0, 0],
        ['I', 0,  0, 0, 0],
        ['I', 0,  0, 0, 0]
        ]
    end

    def test_rotation_F
        pent = Pentamino.new($F)
        rotated = pent.rotate
        
        assert_equal rotated.arrangement, [
            [0,   'F',   0 ],
            ['F', 'F',  'F'],
            [ 0,   0,   'F' ]
        ]
    end

    def test_equality_pentamino
      p1 = Pentamino.new($F)
      p2 = Pentamino.new($F)
      assert_equal p1, p2
    end

    def test_equality_grid
        assert_equal @grid, [
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0],
        ]
    end

    def test_invalid_apply_raises_indexerror
        @grid = Grid.new(2,2)
        p = Pentamino.new($I)
        
        assert_raises IndexError do 
           @grid.apply(0,0, p) 
        end 
    end

end