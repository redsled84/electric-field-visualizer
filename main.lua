local coloumbs_const = 8.975 * math.pow(10, 9)

local function distance(x1, y1, x2, y2)
	return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

local function magnitude(dx, dy)
	return math.sqrt(dx^2 + dy^2)
end

function point_charge_field(x, y, particle_charges)
	local unit_vector = {
		dx = 0,
		dy = 0
	}

	local x_component = 0
	local y_component = 0
	for i = 1, #particle_charges do
		local charge = particle_charges[i]
		local theta = math.atan((charge.y - y) / (x - charge.x))
		local dist  = distance(x, y, charge.x, charge.y)
		x_component = x_component + math.cos(theta) * (charge.c) / dist^2
		y_component = y_component + math.sin(theta) * (charge.c) / dist^2
	end

	x_component = x_component * coloumbs_const
	y_component = y_component * coloumbs_const

	unit_vector.dx = x_component / magnitude(x_component, y_component)
	unit_vector.dy = y_component / magnitude(x_component, y_component)

	return unit_vector
end

local particles = {}
local field = {}

local pico  = math.pow(10, -12)
local nano  = math.pow(10, -9)
local micro = math.pow(10, -6)

function love.load()
	math.randomseed(os.time())
	math.random()
	math.random()
	math.random()

	local offset = 39
	for i = 1, math.random(4, 9) do
		local c = math.random(3, 19) * micro

		if math.random(0, 100) > 50 then
			c = c * -1
		end

		local x = math.random(offset, love.graphics.getWidth() - offset)
		local y = math.random(offset, love.graphics.getHeight() - offset)

		table.insert(particles, {x = x, y = y, c = c})
	end

	-- can be optimized
	local grid_size = 32
	for y = grid_size, love.graphics.getHeight() - grid_size, grid_size do
		for x = grid_size, love.graphics.getWidth() - grid_size, grid_size do
			table.insert(field, {x = x, y = y, u = point_charge_field(x, y, particles)})
		end
	end
end

function love.graphics.arrow(x1, y1, x2, y2, arrlen, angle)
	love.graphics.line(x1, y1, x2, y2)
	local a = math.atan2(y1 - y2, x1 - x2)
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a + angle), y2 + arrlen * math.sin(a + angle))
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a - angle), y2 + arrlen * math.sin(a - angle))
end

function love.draw()
	love.graphics.setColor(1,1,1)
	for i = 1, #field do
		local e = field[i]
		love.graphics.arrow(e.x, e.y, e.x + 8 * e.u.dx, e.y + 8 * e.u.dy, 2, math.pi/4)
	end

	love.graphics.setColor(1,1,1)
	for i = 1, #particles do
		local p = particles[i]
		if p.c < 0 then
			love.graphics.setColor(0,0,1)
		else
			love.graphics.setColor(1,0,0)
		end
		love.graphics.circle('line', p.x, p.y, math.abs(math.floor(p.c / micro)))
	end
end

function love.keypressed(key)
	if key == "r" then
		love.event.quit('restart')
	end
end