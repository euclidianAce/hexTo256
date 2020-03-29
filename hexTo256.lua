#!/usr/bin/env lua
-- validate command line args
local args = {...}
for i, v in ipairs(args) do
	if v:sub(1,1) == "#" then v = v:sub(2, -1) end
	local hex = tonumber(v, 16)
	if not hex then
		error(v .. " is not valid")
	end
	args[i] = {
		hexString = v,
		hex = hex,
		closestDiff = math.huge,
	}
end

-- Color data gotten from:
-- https://jonasjacek.github.io/colors/
local colors = require("data")

-- find closest approximation
local abs = math.abs
local r, g, b = 0xff0000, 0x00ff00, 0x0000ff
local function getDiff(c1, c2)
	local rdiff = ((c1 & r)>>16) - ((c2 & r)>>16)
	local gdiff = ((c1 & g)>>8) - ((c2 & g)>>8)
	local bdiff = (c1 & b) - (c2 & b)

	return abs(rdiff) + abs(gdiff) + abs(bdiff)
end
for _, colorData in ipairs(colors) do
	local colorVal = tonumber(colorData.hexString:sub(2, -1), 16)
	for _, arg in ipairs(args) do
		local diff = getDiff(arg.hex, colorVal)
		if diff < arg.closestDiff then
			arg.closestDiff = diff
			arg.data = colorData
		end
	end
end
-- print value
io.write("|orig.  |~>|preview|approx.|id.|\n")
io.write("|-------|--|-------|-------|---|\n")
for i, v in ipairs(args) do
	local c = v.data
	io.write(" #", v.hexString, " ~> ")
	io.write(string.char(27), "[48;5;", c.colorId, "m")
	io.write("       ", string.char(27), "[0m ")
	io.write(c.hexString, " ", c.colorId, "\n")
end
