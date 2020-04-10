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
local function hexToRGB(hex)
	local val = hex
	if type(hex) == "string" then
		if string.sub(hex, 1, 1) == "#" then
			hex = string.sub(hex, 2, -1)
		end
		val = tonumber(hex, 16)
	end
	return (val&r)>>16, (val&g)>>8, (val&b)
end
local function getDiff(c1, c2)
	local r1, g1, b1 = hexToRGB(c1)
	local r2, g2, b2 = hexToRGB(c2)
	local rdiff = r1-r2
	local gdiff = g1-g2
	local bdiff = b1-b2

	return abs(rdiff) + abs(gdiff) + abs(bdiff)
end
for _, colorData in ipairs(colors) do
	for _, arg in ipairs(args) do
		local diff = getDiff(arg.hex, colorData.hexString)
		if diff < arg.closestDiff then
			arg.closestDiff = diff
			arg.data = colorData
		end
	end
end
-- print value
io.write("|orig.  |preview|~>|preview|approx.|id.|\n")
io.write("|-------|-------|--|-------|-------|---|\n")
local esc = string.char(27) .. "["
local reset = esc .. "0m"
for i, v in ipairs(args) do
	local c = v.data
	local orig = {hexToRGB(v.hexString)}
	print((" #%s %s48;2;%d;%d;%dm       %s ~> %s48;5;%dm       %s %s % 3d "):format(
		v.hexString, esc, orig[1], orig[2], orig[3], reset,
		esc, c.colorId, reset, c.hexString, c.colorId
	))
end
