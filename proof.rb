# test melkman sequence
# A valid melkman sequence follows the following invariants:
# 1. Basic invariants
#   a. No duplicates in the middle of the sandwich
#   b. no skipped nodes can come back
#   c. must have a sandwich form
#   d. if not equal to prev, then also cannot omit current index
#  
# 2. Sandwich "bread" must be connected to the max of the middle
# 3. If prev was inside, then the present cannot break a consequentive chain
# 4. Each cur must be a proper subsequence of prev


def basic_invariants(cur, skipped, current_index, prev) 
  # 0
  if cur.length < 3 then
    raise "#{cur} is too short - CH cannot be made from less than 3 points past the first stage"
  end

  # make sure all indices are positive
  if cur.any? {|value| value < 0} then
      raise "#{cur} has a negative value"
  end 
  
  # 1a
  if cur.length - 1 != (Set.new(cur)).length then
    raise "#{cur} failed basic invariant 1a - duplicate found in the middle of the sandwich"
  end

  # 1b  
  if skipped.intersect?(cur) then
      raise "#{cur} failed basic invariant 1b -> an element was found in skipped set=#{skipped}" 
  end

  # 1c
  if !((cur[0] == cur[-1]) && cur[0] == current_index) then
    raise "#{cur} failed basic invariant 1c - it is not a proper sandwich (first and last are not the same, or its not equal to current_index=#{current_index})"
  end

  # 1d
  if ((prev != cur) && (!cur.include?(current_index)))
    raise "#{cur} failed basic invariant 1d - it is not equal to prev=#{prev}, and does not include current index=#{current_index}"
  end

  true
end

def connected_to_max?(cur)
  if !(cur[1] == (cur[1...-1]).max || cur[-2] == (cur[1...-1]).max) 
    raise "#{cur} failed because the sandwich max was not connected to the edge"
  end
  true
end

def broken_edge_upon_exiting_pocket?(cur)
  if (cur[1] - cur[-2]).abs == 1 && cur.length != 4
    raise "#{cur} failed because prev was inside, and cur broke a sequential edge"
  end
  true
end

def is_subsequence_of_prev?(cur, prev)
  cur_copy = cur.dup
  cur_copy.shift
  cur_copy.pop
  cur_middle = cur_copy 

  if !prev.join(" ").include?(cur_middle.join(" "))    
    raise "#{cur_middle} is not a subsequence of #{prev}"
  end

  return true
end

def validate(melk_out)
  first = melk_out[0]

  # validate first
  if !(first == [2,1,0,2] || first == [2,0,1,2]) 
    raise "#{first} is not of proper form, failing off-rip"
  end

  prev = first

  melk_out.shift
  current_index = 3
  prev_inside = false
  skipped = Set.new
  
  melk_out.each do |step| 
    # if prev == step, just move on
    if prev == step
      prev_inside = true
      skipped.add(current_index)
      current_index += 1
      next
    end    
    
    # validate basic invariants
    basic_invariants(step, skipped, current_index, prev)

    # make sure you're connected to max:
    connected_to_max? (step) # raises
  
    if prev_inside then
      broken_edge_upon_exiting_pocket? (step)
    end

    is_subsequence_of_prev?(step, prev)

    prev = step
    prev_inside = false
    current_index += 1
  end
  
  
  return true
end

 test = [
        [2,1,0,2],
        [3,1,0,2,3]
      ]

puts      validate(test)
