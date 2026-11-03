require "./proof"
require "minitest/autorun"

class TestProof < Minitest::Test

  def test_basic_invariants_1a_raises
    assert_raises(RuntimeError) do 
      basic_invariants([4,3,3,4], [], 4, [])
    end

    assert_raises(RuntimeError) do 
      basic_invariants([3,3,3], [], 3, []) 
      basic_invariants([4,3,2,4,0,4], [], 4, [])
    end
  end

  def test_basic_invariants_happy
    assert basic_invariants([3,2,1,0,3], [], 3, [])
  end

  def test_basic_invariants_1b_raises
    assert_raises(RuntimeError) do
      basic_invariants([3,2,1,0,3], [1], 3, [])
    end

    assert_raises(RuntimeError) do
      basic_invariants([3,2,1,0,3], [3], 3, [])
    end
  end

  def test_too_short_raises
    assert_raises(RuntimeError) do
      basic_invariants([3,3], [], 3, [])
    end
  end

  def test_basic_invariants_1c_raises
    assert_raises(RuntimeError) do
      basic_invariants([3,2,1,0], [], 3, [])
    end
  end

  

  def test_incorrect_index_comes_out_of_pocket_fails
    test = [
        [2,1,0,2],
        [3,2,1,0,3],
        [3,2,1,0,3],
        [4,3,2,1,0,4]
    ]
    
    assert_raises(RuntimeError) do
      validate(test)
    end
  end

  def test_valid_left_right_turn
    t = [
      [2,1,0,2],
      [3,1,0,2,3],
    ]

    assert(validate(t))
  end

  def test_long_convoluted_example
    
    test1 = [
      [2,0,1,2],
      [3, 0, 2, 1, 3]
    ]

    assert_raises(RuntimeError) do
      validate(test1)
    end

    test2 = [
      [2,0,1,2],
      [2,0,1,2],
      [4,2,0,1,4]
    ]
    assert_raises(RuntimeError) do 
      validate(test2)
    end

    
  end

  def test_out_of_order_index
    chain = [
      [2,1,0,2],
      [2,1,0,2],
      [3,2,1,0,3],
      [5,3,2,1,0,5]
    ]

    assert_raises(RuntimeError) do 
      validate(chain)
    end
  end

  def test_long_valid_chain
    chain = [
      [2,1,0,2],
      [3,2,1,3],
      [4,3,2,1,4],
      [5,3,2,1,4,5],
      [5,3,2,1,4,5],
      [7,3,2,1,4,5,7],
      [7,3,2,1,4,5,7],
      [9,1,4,5,7,9],
    ]
    chain2 = [
      [2,1,0,2],
      [3,2,1,3],
      [4,3,2,1,4],
      [5,3,2,1,4,5],
      [5,3,2,1,4,5],
      [7,3,2,1,4,5,7],
      [7,3,2,1,4,5,7],
      [9,7,3,2,1,4,5,9],
    ]
    
    chain3 = [
      [2,1,0,2],
      [3,2,1,3],
      [4,3,2,1,4],
      [5,3,2,1,4,5],
      [5,3,2,1,4,5],
      [7,3,2,1,4,5,7],
      [7,3,2,1,4,5,7],
      [9,4,5,9]
      # interesting case here: 9 can have neighbors that are adjacent, but we must make sure that from index 1 to index -2 , there is no sequential break: ie only breaks if 
      # ie this only breaks if i=1 -> 5, and i=-2 -> 4
    ]

    assert(validate(chain))
    assert(validate(chain2))
    assert(validate(chain3))
  end


  def test_negative_index_fails
    assert_raises(RuntimeError) do
      validate([[2,0,-1,2]])
    end
  end


  def test_far_out
    chain = [
      [2,1,0,2],
      [3,1,0,2,3],
      [4,0,2,3,4],
      [5,4,0,2,3,5]
    ]
    assert validate(chain)
  end
end
