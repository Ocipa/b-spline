# b-spline
## B-spline interpolation

B-spline interpolation of control points of any dimensionality using
[de Boor's algorithm](http://wikipedia.org/wiki/De_Boor%27s_algorithm).

The interpolator can take an optional weight vector, making the
resulting curve a Non-Uniform Rational B-Spline (NURBS) curve if you
wish so.

The knot vector is optional too, and when not provided an unclamped
uniform knot vector will be generated internally.


## Ways to 'Install'

- download the .rblx file from releases and import it into studio or
- copy and paste [bSpline.lua](./bSpline.lua) into a module script

## Examples

### Unclamped Knot Vector

```lua
local replicatedStorage = game:GetService('ReplicatedStorage')
local bSpline = require(replicatedStorage.bSpline)

local points = {
	{-1, 0},
	{-0.5, 0.5},
	{0.5, -0.5},
	{1, 0}
}

local degree = 2

--[[
As we don't provide a knot vector, one will be generated 
internally and have the following form :

var knots = [0, 1, 2, 3, 4, 5, 6];

Knot vectors must have `number of points + degree + 1` knots.
Here we have 4 points and the degree is 2, so the knot vector 
length will be 7.

This knot vector is called "uniform" as the knots are all spaced
uniformly, ie. the knot spans are all equal (here 1).
--]]

for t=0, 1, 0.01 do
	local point = bSpline.interpolate(t, degree, points)
end
```

<img src="./examples/unclamped knot vector.PNG"/>


### Clamped Knot Vector

```lua
local replicatedStorage = game:GetService('ReplicatedStorage')
local bSpline = require(replicatedStorage.bSpline)

local points = {
	{-1, 0},
	{-0.5, 0.5},
	{0.5, -0.5},
	{1, 0}
}

local degree = 2

--[[
B-splines with clamped knot vectors pass through 
the two end control points.

A clamped knot vector must have `degree + 1` equal knots 
at both its beginning and end.
--]]

local knots = bSpline.points2ClampedKnots(degree, points)

for t=0, 1, 0.01 do
	local point = bSpline.interpolate(t, degree, points, knots)
end
```

<img src="./examples/clamped knot vector.PNG"/>


### Closed Curves

```lua
local replicatedStorage = game:GetService('ReplicatedStorage')
local bSpline = require(replicatedStorage.bSpline)

local points = {
	{-1, 0},
	{-0.5, 0.5},
	{0.5, -0.5},
	{1, 0},
	
	-- repeat the first 'degree + 1' points
	{-1, 0},
	{-0.5, 0.5},
	{0.5, -0.5},
}


local degree = 2

-- The number of control points without the last repeated
-- points
local originalNumPoints = #points - (degree + 1)

--[[
Disclaimer: If you are using a unclamped knot vector
with closed curves, you may want to remap the t value
to properly loop the curve.

To do that, remap t value from [0.0, 1.0] to
[0.0, 1.0 - 1.0 / (n + 1)] where 'n' is the number of
the original control points used (discard the last repeated points).

In this case, the number of points is 4 (discarded the last 3 points)
--]]

local maxT = 1 - 1 / (originalNumPoints + 1)

for t=0, 1, 0.01 do
	local point = bSpline.interpolate(t * maxT, degree, points)
end
```

<img src="./examples/closed curves.PNG"/>


### Non-Uniform Rational

```lua
local replicatedStorage = game:GetService('ReplicatedStorage')
local bSpline = require(replicatedStorage.bSpline)

local points = {
	{0, -0.5},
	{-0.5, -0.5},

	{-0.5, 0},
	{-0.5, 0.5},

	{0, 0.5},
	{0.5, 0.5},

	{0.5, 0},
	{0.5, -0.5},
	{0, -0.5}
}


local degree = 2

-- Here the curve is called non-uniform as the knots 
-- are not equally spaced
local knots = {0, 0, 0, 1/4, 1/4, 1/2, 1/2, 3/4, 3/4, 1, 1, 1}

local w = math.pow(2, 0.5) / 2

-- and rational as its control points have varying weights
local weights = {1, w, 1, w, 1, w, 1, w, 1}

for t=0, 1, 0.01 do
	local point = bSpline.interpolate(t, degree, points, knots, weights)
end
```

<img src="./examples/non-uniform rational.PNG"/>


## API
```lua
bSpline.interpolate(t, degree, points, knots, weights)
-- t: position along the curve in the range of 0 to 1
-- degree: degree of the curve. Must be less than or equal to the number
  -- of control points minus 1. degree 1 is linear, degree 2 is
  -- quadratic, degree 3 is cubic, and so on.
-- points: control points that will be interpolated. Can be vectors of
  -- any dumensionality ([x, y], [x, y, z], ...)
-- knots(OPTIONAL): Allow to modulate the control points interpolation
  -- spans on t. Must be a non-decreasing sequence of
  -- number of points + degree + 1 length values.
-- weights(OPTIONAL): Must be the same length as the points array.

--> returns: t position along the curve
```

```lua
bSpline.points2ClampedKnots(degree, points)
-- degree: degree of the curve.
-- points: control points that will be interpolated. Can be vectors of
  -- any dumensionality ([x, y], [x, y, z], ...)

--> returns: array of knots
```
