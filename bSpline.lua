local module = {}

function module.points2ClampedKnots(degree, points)
	local middleKnotsNum = #points + degree + 1 - 6

	local startKnots = {0, 0, 0}
	local middleKnots = {}
	local endKnots = {1, 1, 1}

	for i=1, middleKnotsNum do
		local value = 1 / (middleKnotsNum + 1) * i

		table.insert(middleKnots, value)
	end

	local knots = {}
	table.move(startKnots, 1, #startKnots, #knots + 1, knots)
	table.move(middleKnots, 1, #middleKnots, #knots + 1, knots)
	table.move(endKnots, 1, #endKnots, #knots + 1, knots)

	return knots
end

function module.points2UnclampedKnots(degree, points)
	local knots = {}

	for i=1, #points + degree + 1 do
		knots[i] = i
	end

	return knots
end

function module.interpolate(t, degree, points, knots, weights, result)
	local i, j, s, l = nil
	local n = #points
	local d = #points[1]

	assert(degree and degree >= 1, '[ERROR]: bSpline interpolate: degree must be at least 1')
	assert(degree and degree <= n-1, '[ERROR]: bSpline interpolate: degree must be less than or equal to the number of points - 1')

	if not weights then
		weights = {}

		for i2=1, n do
			i = i2
			weights[i] = 1
		end
	end

	knots = knots or module.points2UnclampedKnots(degree, points)
	assert(#knots == n + degree + 1, '[ERROR]: bSpline interpolate: knots need to equal the point count + degree + 1')

	local domain = {
		degree + 1,
		#knots - degree
	}


	local low = knots[domain[1]]
	local high = knots[domain[2]]
	t = t * (high - low) + low

	assert(t >= low and t <= high, '[ERROR]: bSpline interpolate: out of bounds')

	for s2=domain[1], domain[2] do
		s = s2

		if t >= knots[s] and t <= knots[s + 1] then
			break
		end
	end


	local v = {}
	for i2=1, n do
		i = i2
		v[i] = {}

		for j2=1, d do
			j = j2
			v[i][j] = points[i][j] * weights[i]
		end

		v[i][d + 1] = weights[i]
	end


	local alpha = nil
	for l2=1, degree + 2 do
		l = l2

		for i2=s, s - degree + l, -1 do
			i = i2
			alpha = (t - knots[i]) / (knots[i + degree + 1 - l] - knots[i])

			for j2=1, d + 1 do
				j = j2
				v[i][j] = (1 - alpha) * v[i - 1][j] + alpha * v[i][j]
			end
		end
	end

	local result = result or {}
	for i=1, d do
		result[i] = v[s][i] / v[s][d + 1]
	end

	return result
end


return module
