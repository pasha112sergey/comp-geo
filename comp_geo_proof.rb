class Deque
    attr_reader :deq

    def length
      @deq.length
    end

    def shift
      @deq.shift
    end

    def pop
      @deq.pop
    end

    def reverse!
      @deq.reverse!
    end

    def reverse
      @deq.reverse
    end

	def [](*arg)
		@deq[*arg]	
	end
	
	def initialize (arr)
		@deq = arr
	end

    def to_s
      @deq.to_s
    end

    def connected_to_max?
      second_max = @deq[1...-1].max
      if !(@deq[1] == second_max || @deq[-2] == second_max) then 
            return false
      end 
    end

    def breaking_crossings? 
      if (@deq[1] - @deq[0]).abs == 1 then
            return false
      end 
    end

    def basic_invariants_satisfied? (skipped, i) # just test basic invariants
        if ((Set.new @deq) & skipped).empty? == false then
            p "#{(Set.new @deq) & skipped} - we already skipped!"
            return false
        end

        if (Set.new(@deq)).length !=  @deq.length - 1 then
            p "Length doesn't match: len of set = #{(Set.new(@deq)).length}, set of de-duped deq: #{@deq.length - 1}"
            return false
        end

        if (@deq[0] != @deq[-1]) then
            p "#{@deq} is not a sandwich"
            return false
        end
        
        valid_chain = @deq.all? { |ele| ele <= i}
        if !valid_chain then
            p "found an chain index that is larger than the current step! #{@deq}, #{i}"
            return false
        end

        if !connected_to_max? then
          p "new node #{@deq[0]}, chain=#{@deq} does not have a proper connection to the maximum node on the CH #{@deq[1...-1].max}"
        end

        return true
    end

    def unwrapped_clockwise?(prev) # checks if the grid is an unwrapped version of prev?
        # clockwise here means that my unwrap went clockwise
        middle = Deque.new(Array.new(@deq)) # copy
        middle.shift
        middle.pop

        # start from 0 to prev.len - middle.len
        for i in 0..(prev.length - middle.length) do
            if prev[i, middle.length] == middle then 
                return true
            end
        end
        
        p "#{middle} was not found as a contiguous substring starting from the clockwise in #{prev}"
        return false
    end

   def unwrapped_counterclockwise?(prev)
        p "unwrapped counter clockwise recieved prev=#{prev}"
      
        middle = Deque.new(Array.new(@deq)) # copy
        middle.shift
        middle.pop
        middle.reverse!

        reversed_prev = prev.reverse
        p "reversed prev is: #{reversed_prev}"
        for i in 0..(reversed_prev.length - middle.length) do
            if reversed_prev[i, middle.length] == middle then
            return true
            end
        end
        p "#{middle} was not found as a contiguous substring unwrapped counterclockwise from #{prev}"
        false
    end

    def unwrap_from?(prev, i) # check if its a valid unwrap (2pointers)
        # if unwrapped_clockwise?(prev) || unwrapped_counterclockwise?(prev) then
        #     p "was able to unwrap #{@deq} from #{prev}!"
        #     return true
        # end
        # say middle is a proper substring of the prev?

        middle = Deque.new(Array.new(@deq))
        middle.shift
        middle.pop
        p "middle=#{middle.to_s}, prev=#{prev.to_s}; #{prev.to_s[1...-1][middle.to_s[1...-1]] }"
        
        if prev.to_s[1...-1][middle.to_s[1...-1]] != nil then
            p "#{middle} is a proper substring of prev=#{prev}"
          return true
        end

        p "failing to unwrap #{@deq} from prev=#{prev}, i=#{i}" 
        return false
    end

    def same?(other) # checks if deqs are the same 
        @deq == other.deq
    end

    def valid_start?()
        return @deq == [2,1,0,2] || @deq == [2,0,1,2]
    end
end


class Solver
    def self.solve(problem)
        if !Deque.new(problem[0]).valid_start? then
          return false
        end

        prev_raw = problem.shift
        prev = Deque.new prev_raw

        skipped = Set.new
        i = 3
        for d in problem do
            deq = Deque.new d

            if !deq.basic_invariants_satisfied?(skipped, i) then
              return false
            end

            if !(deq.unwrap_from?(prev, i) || deq.same?(prev)) then
                p "failing at stage: #{deq}, i=#{i} prev=#{prev}. deq.same = #{deq.same? prev}"
              return false
            end

            prev = deq
            i += 1
        end

        return true
    end
end

=begin
  idea: 
	for each deq step, try to unwrap the previous
		
	case analysis:
		case a:
			removing some vertices:
			invariant: must be unwrapping to the left,
			unwrapping to the right
			unwrapping both, sequentially in the convex hull walk sense


		case b:
			adding a new vertex:
			invariant: must be connected to the next biggest vertex on the rest of the CH
		
		case c:
			no change at all => move on

=end

def main
	failing_1 = [
		[2,1,0,2],
		[2,1,0,2],
		[4,1,0,2,4]
	]

    passing_1 = [
        [2,1,0,2],
        [3,2,1,0,3],
        [4,3,2,1,0,4],
        [5,4,3,2,1,0,5],
        [6,4,3,2,1,0,6]
    ]

	puts Solver.solve(failing_1)
    puts "===================="
    puts Solver.solve(passing_1)
end

if __FILE__ == $0 then
	main
end