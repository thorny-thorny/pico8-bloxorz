function background_create()
	local background = {
    draw = background_draw,
	}

	return background
end

function background_draw(self)
	map(112, 34, 0, 0, 16, 16)
end
