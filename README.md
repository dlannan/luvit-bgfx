#luvit-bgfx

The project is a combination of the brilliant luvit project with the renderer bgfx.
Individual projects can be found here:

Luvit  - https://github.com/luvit/luvit
bgfx   - https://github.com/bkaradzic/bgfx

Also for gui interface systems 
nanovg - https://github.com/memononen/nanovg

Bindings for luvit (lujit ffi internally) are provided to directly execute bgfx methods from lua script.

##Hello World Example
For example bgfx hello world becomes:
```
local ffi = require('ffi')

-- Setup the SDL Window and it returns a bgfx handle to use
local sdl = require('sdl2-setup')
local bgfx = require('bgfx-setup')
local utils = require('bgfx-utils')

local event = ffi.new('SDL_Event')
local sdltimer = nil

local m_width = 640
local m_height = 400
local m_debug = BGFX_DEBUG_TEXT
local m_reset = BGFX_RESET_VSYNC

local projMtx, viewMtx, mdlMtx = utils.matrixinit()

function init()
    bgfx.bgfx_set_debug(m_debug)
    bgfx.bgfx_set_view_clear(0, bit.bor(BGFX_CLEAR_COLOR, BGFX_CLEAR_DEPTH), 0x303030ff, 1.0, 0)

    bgfx.bgfx_reset( m_width, m_height, m_reset )
    bgfx.bgfx_set_view_rect(0,0,0, m_width, m_height)
    projMtx = utils.makeortho( projMtx, 0, m_width, m_height, 0, 0, 2)
end

function shutdown()
    bgfx.bgfx_shutdown()
    sdl.destroyWindow(window)
    sdl.quit()
    return 0
end

function update()
    
    bgfx.bgfx_set_view_seq(0, true)
    bgfx.bgfx_set_view_transform(0, viewMtx, projMtx)

    bgfx.bgfx_touch(0)
    bgfx.bgfx_dbg_text_clear(0, false)
    
-- Image texture not yet working.
--    bgfx.dbgTextImage(   ((m_width /2 /8), 20) - 20,
--                        ((m_height /2 /16), 6) - 6,
--                        40, 12, s_logo, 160)
                        
    bgfx.bgfx_dbg_text_printf(0, 1, 0x4f, "bgfx/examples/00-helloworld")
    bgfx.bgfx_dbg_text_printf(0, 2, 0x6f, "Description: Initialization and debug text.")
    
    bgfx.bgfx_dbg_text_printf(0, 4, 0x0f, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.")

    local stats = bgfx.bgfx_get_stats()
    bgfx.bgfx_dbg_text_printf(0, 6, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
            , stats.width
            , stats.height
            , stats.textWidth
            , stats.textHeight)

    bgfx.bgfx_frame(false)
    while sdl.pollEvent(event) ~= 0 do
      if event.type == sdl.QUIT then
        timer.clearTimer(sdltimer)
        shutdown()
      end
    end
end

timer = require('timer')
init()
sdltimer = timer.setInterval(20, update)
```

##Executing Examples:
Open in console and run the following command.
```
.\bin\luvit.exe .\run_example.lua sdl2-example-01.lua
or
.\bin\luvit.exe .\run_example.lua glfw-example-01.lua
```
