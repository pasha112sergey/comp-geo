# Melkman Inverse

### Sergey Safronov

### November 2026

# Introduction

In CSE/AMS 345, we are interested in the "inverse" problem of Melkman's linear-time convex-hull finding algorithm. Formally defined, it is:

# Problem Statement

Does a particular ordered collection `A` of arrays of integers, `A_i`, correspond to an output from Melkman’s linear-time convex-hull algorithm on a valid (simple non-crossing) chain?

# Conventions, IO, and terminology

We call the input `melk_out: Integer[][]`, which stands for Melkman output. Each entry in `melk_out` is an array we call `step: Integer[]`. We are taking each `step` to correspond to the output of the Melkman algorithm when the `i+2`th point is considered.

> Note: the algorithm conventionally starts at the first non-trivial chain: either <2,1,0,2> or <2,0,1,2>. Hence, the first entry in `melk_out` corresponds to the 2nd point considered.

As per conventions, I am considering the mainstream implementation of Melkman's algorithm, meaning that each `step` corresponds to the clockwise convex hull when `i+2` points are considered.

Likewise, all indices are 0-based, implying all inputs are taken to be unsigned integers.

We aim to solve the decision problem, meaning the algorithm must return a `boolean` value.

# Invariants

Our approach is to try to analyze what sorts of invariants a valid Melkman output would have, and then checking an instance input against them iteratively.

First, let's constrain an arbitrary array of `Integers` to ones that _"look"_ like possible Melkman outputs.

Since Melkman's algorithm keeps a deque data structure, all of our arrays must be of a _sandwich_ form, leading to the following first invariant, which we will revise later:

> [!Important]
>
> 1. Each array `melk_out[i]` must be of form `[n, ..., n]` for some integer `n`, `i` $\in$ `[0, length(melk_out) + 2]`

Next, we have

> [!IMPORTANT]
>
> 2. `melk_out[i][1:-1]` cannot have duplicates

The proof for this is trivial. If a point `j` is present two or more times in the middle of the sandwich, it implies that it shows up at two or more places on the convex hull, which is impossible. Each point can only be present at at most on place on the boundary of the convex hull.

Lastly,

> [!IMPORTANT]
>
> 3. Given a set `skipped[i]: Set<Integer>`, corresponding to all the nodes that were marked internal before the `i+2`th point was considered, `melk_out[i]` $\bigcap$ `skipped[i]` == `{ }` (empty set)

This is because once a node has been marked as internal in the convex hull, we cannot unwrap the hull in such a way as to make that node a member on the convex hull. Notice that this is not the case for the converse. Nodes that are on the convex hull, can lose their _convexity status_ as we analyze more points along the simple chain. We discuss this in the next section.

We can also say that we will have at least 3 points in a valid output, meaning that, with the duplicate top and bottom points, we have:

> [!IMPORTANT]
>
> 4. `len(melk_out[i])` $\ge 4 \space \forall i \in [0,$ `len(melk_out)`$]$

## What happens at each step

Now, let's analyze what can happen at a given step `i`.

Assuming that the previous convex hull was valid, the chain can do one of the following 3 things:

**Case A:** The new point can extend the convex hull without updating the relative convexity of previous points
**Case B:** The new point can go inside of a convex pocket, making the node "internal" to the convex hull
**Case C:** Extend the convex hull in a way that removes some nodes from the _new_ convex hull (I'll call this **unwrapping**)

Visually, the cases look like the following:
![alt text](image.png)

> Imagine that the convex hull is abstractly represented by the curved line, with `q` < `p`
> Note that case C could unwrap from either side of the convex hull - removing either from the left, or the right in this example. We will prove that these cases are identical, and, can therefore be labeled the same.

Before we start, notice that in every case other than **Case B**, the point will be on the new deque of the convex hull. This leads us to the revision of our first invariant

> [!IMPORTANT]
>
> 4. If `melk_out[i] != melk_out[i-1]`, then `i-2` $\in$ `melk_out[i]`. More specifically, following the _sandwich_ invariant, we know that `melk_out[i]` must be of form `[(i+2), ..., (i+2)]`

Now, let's dive into the cases:

#### Case A

---

This one is pretty trivial. We know that for a previous arrangement called `prev := melk_out[i-1]`, and a new point `s`, we will have the following form:

> [!IMPORTANT]
>
> **Case A** can only be of the form `[s, melk_out[i-1], s]`

This follows directly from the definition of Case A. We are _preserving_ everything that we had previously, and **adding** the new point to the convex hull.

#### Case B

---

Case B is our internal case. From the initial look, it's really simple. To be internal, is to be omitted from the convex hull. Meaning, to detect if we are in **Case B**, we just need to check if

> [!IMPORTANT]
>
> **Case B** can be uniquely identified at step `i` if `melk_out_[i] == melk_out[i-1]`.

Can **Case B** always happen? Yes! This is because the convex hull always has a pocket between the first point and the last point. In Melkman notation, this means that

On our diagram above, that is the pocket between points `p` and `q`.

> [!IMPORTANT]
>
> In fact, we can detect a pocket by the fact that on the convex hull, the difference between two _(circularly)_ adjacent vertices is more than 1.

> Proof:
> Given a convex hull of a simple, non-crossing, integer indexed chain, we know that if the difference between two adjacent vertices `p` and `q` (with `p` < `q`) is 1, then the `p` directly is connected to `q`. The term _directly_ connected means that the edge from `p` to `q` on the chain is exactly the edge from `p` to `q` on the convex hull. This follows from the fact that the chain is connected and indexed in a sequential manner.
>
> ![alt text](image-1.png)
>
> > _Example diagram of direct connection_
>
> Now let's consider what happens if the difference is more than one. Since the point indexed `p+1` is not directly on the convex hull, we know that it is internal to the hull. Hence, there is a **pocket** between that point `p+1`, and the edge of the convex hull from `p` to `q`
> ![alt text](image-2.png)
>
> > _Example diagram of pocket. P+1 is internal to the convex hull edge `pq`, meaning that it, and all of its successors that are not `q` form a pocket (denoted by the region between the red and green dashed edges). You can have arbitrarily many red vertices after `P+1` and preserve the pocket_

This implies that:

> [!IMPORTANT]
> There is always a pocket between `melk_out[i][1]` and `melk_out[i][-2]` because the difference $ p-q > 1$, meaning that at any point, we can encounter **Case B**.

#### Case C

---

This is the unwrapping case. The term _unwrapping_ here means that we are popping off nodes sequentially from our convex hull.

Tying our problem back to the Melkman Algorithm, this happens in the left test loop, which continually pops off points from either the top or the bottom of the deque (or both).

This implies that the middle of a sandwich at step `i` must be a subsequence of the step at `i-1`. Formally:

> [!IMPORTANT]
>
> `melk_out[i][1:-2]` is a substring of `melk_out[i-1]`

This, paired with our **trivial invariant 4** means that at any step, we can unwrap to a triangle. This is interesting, because though it is not always true for a particular instance, it _is_ always true for the decision problem, because you can redraw your chain by making some edges shorter, until

![alt text](image-3.png)

> Example of the above statement. Given the chain on the left, there is no way to make force the deque <5,1,0,5>. However, if we just perturb 0 to left and 1 to the right, we can force it, while preserving the output we had prior to considering point 5.

Notice that **Case A** is actually a special **Case of C**, since it is the case where we continually unwrap 0 points.

Another thing we notice is that: the point `p` that we are considering must be connected to the point `q := max(melk_out[i][1:-2])`. This leads us to the necessary condition that:

> [!IMPORTANT]
> `melk_out[i][1] == max(melk_out[i][1:-2]) or melk_out[i][-2] == max(melk_out[1:-2])`

> Proof:
> Since the point indices are always increasing, the path from point `q` must be connected to `q+1`, which must be connected to `q+2` and so on. Eventually, `q` must be connected via a path to our new max point `p`. If `p > q+1`, we have a pocket. Otherwise, `p == q=1`. A connection is denoted by the adjacency in `melk_out[i]`. Following revised invariant 1, `p` is at `melk_out[i][0]` and `melk_out[i][-1]`. For it to be connected to this point `q`, that point must be adjacent in the `melk_out[i]` array, leaving contender indices `1` or `-2`.

#### Are we done?

---

We are **almost** done! We have covered and proved some necessary conditions for the simple chain, but how do we know that these conditions are sufficient? Not yet.

So far, we analyzed simple cases for a chain that was never internal. However, the following instance follows all of our invariants, but it is not valid. Consider the following input:

```python
melk_out = [
    [2,1,0,2],
    [2,1,0,2],
    [4,1,0,2,4]
]
```

Let's check based on our invariants:

1. `i = 0, melk_out[i] = [2,1,0,2]` is one of two valid starts $\checkmark$

2. `i = 1, melk_out[i] = [2,1,0,2]` We notice that `melk_out[i=1] == melk_out[i == 0]`, meaning that we are in **Case B**. Since we said that this could occur at any chain, this is still valid. $\checkmark$

3. `i = 2, melk_out[i] = [4,1,0,2,4]`. Let's check:
   a. Biggest point is on the outsides of the sandwich $\checkmark$
   b. The middle of the sandwich is a substring of the previous answer $\checkmark$
   c. The `max` of the middle of the sandwich should be at index 1 or -2 $\checkmark$
   d. `len(melk_out[i]) > 4` $\checkmark$
   e. At this point, skipped = `{3}`, and `melk_out[i]` does not contain 3. $\checkmark$
   f. There are no duplicates other than the outside of the sandwich $\checkmark$

All invariant checks pass, so we're good, right?

False! This instance actually corresponds to the following self-crossing chain (and any isomorphic instance thereof).

![alt text](image-4.png)

So what did we miss? When our previous step is internal, then we have an extra constraint. Given that `melk_out[i-1]` is internal, `melk_out[i]` has the additional constraint that, if it was not also internal (ie if not `melk_out[i-1] == melk_out[i]`), then `i` can only emerge from the pocket. Intuitively, this means that we can come out of a chain and unwrap a pocket up until we make the convex hull a triangle.

We can write this in the following way

> [!IMPORTANT]
>
> Given the flag `prev_internal == True` that denotes whether `melk_out[i-1]` was marked as an internal point, we cannot have that `abs(melk_out[i][1] - melk_out[i][-2]) == 1`, unless `len(melk_out) == 4`.

> Proof:
> We know that a point `s` can only be in an internal state if it entered a pocket. A pocket is defined by a convex hull edge from `p` to `q`, which we will call the _mouth_ of the pocket. WLOG, suppose `p` is on the left of `s`, and `q` is on its right, and `q > p`.
>
> ![alt text](image-5.png)
>
> When `s` comes out, it necessarily must come out through the _mouth_ of the pocket, unwrapping an arbitrary amount of points from its left and its right. Notice that this unwrapping _travels_ in opposite directions, meaning that the difference of `p` and `q` is never 1, until precisely the moment when we unwrap to the triangle convex hull with `p*` and `q*` forming an edge (with their difference being 1). This means that at all times when `s` unwraps the convex hull to an `n`-gon with `n > 3`, the left point `p*` and right point `q*` must be separated by a distance $\ge 1$.

Now, we have analyzed everything that a valid chain can do. In summary, any node we should consider iteratively can do one of 4 valid things:

1. Continue the convex hull without updating the convexity of previous nodes
2. Become, internal to the convex hull
3. If it was internal to the convex hull previously, it can stay internal, or legally exit through a pocket.
4. Unwrap an arbitrary amount of points from the left and or the right side of the hull.

## Time Complexity

Now, the algorithm in `proof.rb` runs in `O(m * n)` time by checking all of the _Important!_ invariants, where `m` is the number of Melkman iterations, and `n` is the max length of each iteration. Each invariant check is `O(n)`, which we perform `m` times, resulting in `O(m*n)`
