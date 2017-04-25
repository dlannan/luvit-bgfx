package.path = package.path..";?/init.lua"

local sdl = require 'sdl2'
local ffi = require 'ffi'

local w = 640
local h = 400
local whChanged = true

sdl.init(sdl.INIT_VIDEO)

local window = sdl.createWindow("Hellow World",
                                sdl.WINDOWPOS_CENTERED,
                                sdl.WINDOWPOS_CENTERED,
                                w,
                                h,
                                sdl.WINDOW_OPENGL)

--local image = sdl.loadBMP("images/lena.bmp")
--sdl.upperBlit(image, nil, windowsurface, nil)
--sdl.freeSurface(image)
sdl.gL_SetAttribute( sdl.GL_DOUBLEBUFFER, 1)
sdl.gL_CreateContext( window )

local windowsurface = sdl.getWindowSurface(window)
sdl.updateWindowSurface(window)

return sdl