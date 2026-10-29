require "minitest/autorun"
require_relative "comp_geo_proof"

class TestProof < Minitest::Test
  def setup 
  end

  def test_unwrapped_counterclockwise
    prev = Deque.new [2,1,0,2]
    _next = Deque.new [3,2,1,0,3]
    assert _next.unwrapped_counterclockwise? prev
  end
end
