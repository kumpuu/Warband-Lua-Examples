--By Trey Reynolds
--[[
This Lua module can be used to read, edit and write a specific kind of .bmp file.
The bitmap file format was reverse engineered from Microsoft Paint's 24-bit bmp format.
It seems to work on most bitmaps.

If a function is unable to execute, it will return nil and a message explaining why it failed.

To make a new bitmap canvas, use:
	canvasobject=canvas.new(width,height,r,g,b)
	r g and b default to 0.

To load a bitmap file, use:
	canvasobject=canvas.load(path,gammacorrection)
	gammacorrection defaults to false.

To get a value of a pixel, use:
	r,g,b=canvasobject:get_pixel(x,y)

To set a value of a pixel, use:
	canvasobject:set_pixel(x,y,r,g,b)
	It is significantly faster to run through all x, then switch y.

To save a bitmap file, use:
	bytedata=canvasobject:save(path,gammacorrect)
	gammacorrect defaults to the setting used when opening the file.


The MIT License (MIT)

Copyright (c) 2015 AxisAngles

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

canvas			= {}
local char		=string.char
local byte		=string.byte
local sub		=string.sub
local rep		=string.rep
local concat	=table.concat
local open		=io.open

local function writeint(n)
	local r0=n%256
	n=(n-r0)/256
	local r1=n%256
	n=(n-r1)/256
	local r2=n%256
	n=(n-r2)/256
	local r3=n%256
	return char(r0,r1,r2,r3)
end

local function save(self,path,gamma)
	local h=self.h
	local w=self.w
	local gamma=gamma==nil and self.gamma or gamma
	local rlist=self.r
	local glist=self.g
	local blist=self.b
	local n=1
	local excess=-3*w%4
	local bytes=h*(3*w+excess)
	if 2^32-1<bytes then
		--error("file is too big to save")
		return nil,"file is too big to save"
	end
	local lineend=rep('\0',excess)
	local bmp={
		"BM"									--Header
		..writeint(54+bytes)					--Total file size.
		.."\0\0\0\0\54\0\0\0\40\0\0\0"			--40 defines color definition size
		..writeint(w)..writeint(h)				--Width by height
		.."\1\0\24\0\0\0\0\0"					--Defines 24 bit color
		..writeint(bytes)						--Total pixel byte length
		.."\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"	--Space that we don't use
	}
	for i=1,h do
		for j=1,w do
			local r,g,b
			if gamma then
				r=255*rlist[(i-1)*w+j]^(1/2.2)
				g=255*glist[(i-1)*w+j]^(1/2.2)
				b=255*blist[(i-1)*w+j]^(1/2.2)
			else
				r=255*rlist[(i-1)*w+j]
				g=255*glist[(i-1)*w+j]
				b=255*blist[(i-1)*w+j]
			end
			n=n+1
			--char automatically rounds to nearest integer
			bmp[n]=char(b<0 and 0 or 255<b and 255 or b~=b and 0 or b,
				g<0 and 0 or 255<g and 255 or g~=g and 0 or g,
				r<0 and 0 or 255<r and 255 or r~=r and 0 or r)
		end
		n=n+1
		bmp[n]=lineend
	end
	local data=concat(bmp)
	if path then
		local file=open(path,"wb")
		file:write(data)
		file:close()
	end
	return data
end

-- 5x7 pixel font for numbers 0-9
local font_5x7 = {
    ['0'] = {
        "01110",
        "10001",
        "10011",
        "10101",
        "11001",
        "10001",
        "01110"
    },
    ['1'] = {
        "00100",
        "01100",
        "00100",
        "00100",
        "00100",
        "00100",
        "01110"
    },
    ['2'] = {
        "01110",
        "10001",
        "00001",
        "00010",
        "00100",
        "01000",
        "11111"
    },
    ['3'] = {
        "11111",
        "00010",
        "00100",
        "00010",
        "00001",
        "10001",
        "01110"
    },
    ['4'] = {
        "00010",
        "00110",
        "01010",
        "10010",
        "11111",
        "00010",
        "00010"
    },
    ['5'] = {
        "11111",
        "10000",
        "11110",
        "00001",
        "00001",
        "10001",
        "01110"
    },
    ['6'] = {
        "00110",
        "01000",
        "10000",
        "11110",
        "10001",
        "10001",
        "01110"
    },
    ['7'] = {
        "11111",
        "00001",
        "00010",
        "00100",
        "01000",
        "01000",
        "01000"
    },
    ['8'] = {
        "01110",
        "10001",
        "10001",
        "01110",
        "10001",
        "10001",
        "01110"
    },
    ['9'] = {
        "01110",
        "10001",
        "10001",
        "01111",
        "00001",
        "00010",
        "01100"
    }
}

local function newblank(w,h)
	local rlist={}
	local glist={}
	local blist={}
	local newcanvas={
		w=w;
		h=h;
		save=save;
		r=rlist;
		g=glist;
		b=blist;
		--These are hard coded in here to speed up the Lua version
		--Costs an extra 168 kb lol
		set_pixel_int = function(self,x,y,r,g,b,a)
			if x<1 or x>w or y<1 or y>h then return end
			a = a or 1

			local p=(y-1)*w+x
			rlist[p] = rlist[p] + (r - rlist[p])*a
			glist[p] = glist[p] + (g - glist[p])*a
			blist[p] = blist[p] + (b - blist[p])*a
		end;

		--sub pixel drawing
		set_pixel = function(self,x,y,r,g,b,a)
			if x<0 or x>w+1 or y<0 or y>h+1 then return end

			-- Check if x,y are floats (subpixel)
		    local x_int = math.floor(x)
		    local y_int = math.floor(y)
		    local fx = x - x_int  -- fractional part (0 to 1)
		    local fy = y - y_int  -- fractional part (0 to 1)
		    
		    -- If coordinates are integers, just draw as normal
		    if fx == 0 and fy == 0 then
		        return self:set_pixel_int(x,y,r,g,b,a)
		    end

		    -- local function easeInCubic(x)
			-- 	-- return math.pow(x, 3);
			-- 	-- return (x < 0.5) and (4 * x * x * x) or 1 - math.pow(-2 * x + 2, 3) / 2;
			-- 	return (x < 0.5) and (16 * x * x * x * x * x) or 1 - math.pow(-2 * x + 2, 5) / 2;
			-- end
			-- fx = easeInCubic(fx)
			-- fy = easeInCubic(fy)

	        -- Pixel 1: bottom-left (main pixel)
			a = a or 1
		    local a2

		    a2 = (1 - fx) * (1 - fy) * a
		    if a2 > 0 then self:set_pixel_int(x_int, y_int, r,g,b,a2) end
		    
		    -- Pixel 2: bottom-right
		    a2 = fx * (1 - fy) * a
		    if a2 > 0 then self:set_pixel_int(x_int+1, y_int, r,g,b,a2) end
		    
		    -- Pixel 3: top-left
		    a2 = (1 - fx) * fy * a
		    if a2 > 0 then self:set_pixel_int(x_int, y_int+1, r,g,b,a2) end

		    -- Pixel 4: top-right
		    a2 = fx * fy * a
		    if a2 > 0 then self:set_pixel_int(x_int+1, y_int+1, r,g,b,a2) end
		end,

		get_pixel = function(self,x,y)
			if 1<=x and x<=w and 1<=y and y<=h then
				local p=(y-1)*w+x
				return rlist[p],glist[p],blist[p]
			end
			return 0,0,0
		end;

		-- Draw a single digit at position (x, y) with color (r, g, b)
		-- spacing: pixels between digits (default 1)
		draw_digit = function(self, digit, x, y, r, g, b)
		    local pattern = font_5x7[digit]
		    if not pattern then return end
		    
		    for row = 1, 7 do
		        for col = 1, 5 do
		            if pattern[row]:sub(col, col) == '1' then
		                self:set_pixel(x + col - 1, y + 7 - row, r, g, b)
		            end
		        end
		    end
		end,

		-- Draw a string of numbers at position (x, y)
		-- Returns the width used
		draw_number = function(self, number_str, x, y, r, g, b, spacing)
		    spacing = spacing or 1
		    
		    local num_str = tostring(number_str)
		    local char_width = 5 + spacing
		    local current_x = x
		    
		    for i = 1, #num_str do
		        local char = num_str:sub(i, i)
		        if char:match("%d") then
		            self:draw_digit(char, current_x, y, r, g, b)
		        end
		        current_x = current_x + char_width
		    end
		    
		    -- Return total width
		    return #num_str * char_width - spacing
		end,

		-- Optional: Draw with scale factor (bigger numbers)
		draw_number_scaled = function(self, number_str, x, y, r, g, b, scale, spacing)
		    scale = scale or 1
		    spacing = spacing or 1
		    
		    local num_str = tostring(number_str)
		    local char_width = 5 * scale + spacing
		    local current_x = x
		    
		    for i = 1, #num_str do
		        local char = num_str:sub(i, i)
		        if char:match("%d") then
		            local pattern = font_5x7[char]
		            if pattern then
		                for row = 1, 7 do
		                    for col = 1, 5 do
		                        if pattern[row]:sub(col, col) == '1' then
		                            -- Draw a scaled pixel (scale x scale block)
		                            for sy = 0, scale - 1 do
		                                for sx = 0, scale - 1 do
		                                    self:set_pixel(
		                                        current_x + (col - 1) * scale + sx,
		                                        y + (row - 1) * scale + sy,
		                                        r, g, b
		                                    )
		                                end
		                            end
		                        end
		                    end
		                end
		            end
		        end
		        current_x = current_x + char_width
		    end
		    
		    return #num_str * char_width - spacing
		end,

		-- line algorithm with subpixel support
		draw_line = function(self, x1, y1, x2, y2, r, g, b)
		    local dx = math.abs(x2 - x1)
		    local dy = math.abs(y2 - y1)
		    local sx = x1 < x2 and 1 or -1
		    local sy = y1 < y2 and 1 or -1
		    local err = dx - dy
		    local steps = math.max(dx, dy)  -- Fixed number of iterations
		    
		    for i = 0, steps do
		        self:set_pixel(x1, y1, r, g, b)
		        
		        if i >= steps then break end
		        
		        local e2 = 2 * err
		        if e2 > -dy then
		            err = err - dy
		            x1 = x1 + sx
		        end
		        if e2 < dx then
		            err = err + dx
		            y1 = y1 + sy
		        end
		    end
		end,
	}

	return newcanvas,rlist,glist,blist
end

local function readint(bmp,i)
	local r0,r1,r2,r3=byte(bmp,i,i+3)
	return r0+256*r1+65536*r2+16777216*r3
end

function canvas.open(path,gamma)
	local file=open(path,"rb")
	local bmp=file:read("*all")
	file:close()
	if readint(bmp,7)~=0 or readint(bmp,11)~=54 or readint(bmp,15)~=40 then
		--error("file is not supported")
		return nil,"file is not supported"
	end
	local w=readint(bmp,19)
	local h=readint(bmp,23)
	local newcanvas,rlist,glist,blist=newblank(w,h)
	newcanvas.gamma=gamma or false
	local rowbytes=3*w+-3*w%4
	for i=1,h do
		for j=1,w do
			local m=rowbytes*i+3*j+52-rowbytes
			local b,g,r=byte(bmp,m,m+2)
			local p=(i-1)*w+j
			if gamma then
				--This is so wrong.
				rlist[p]=(r/255)^2.2
				glist[p]=(g/255)^2.2
				blist[p]=(b/255)^2.2
			else
				rlist[p]=r/255
				glist[p]=g/255
				blist[p]=b/255
			end
		end
	end
	return newcanvas
end

function canvas.new(w,h,r,g,b)
	r=r or 0
	g=g or 0
	b=b or 0
	local newcanvas,rlist,glist,blist=newblank(w,h)
	for i=1,h do
		for j=1,w do
			local p=(i-1)*w+j
			rlist[p]=r
			glist[p]=g
			blist[p]=b
		end
	end
	return newcanvas
end
