luvit-bgfx

The project is a combination of the brilliant luvit project with the renderer bgfx.
Individual projects can be found here:

Luvit  - https://github.com/luvit/luvit
bgfx   - https://github.com/bkaradzic/bgfx

Also for gui interface systems 
nanovg - https://github.com/memononen/nanovg

Bindings for luvit (lujit ffi internally) are provided to directly execute bgfx methods from lua script.

For example bgfx hello world becomes:
-----------------------------------------------------------------------------------
local m_width = 1280
local m_height = 720
local m_debug = bgfx.BGFX_DEBUG_TEXT
local m_reset = bgfx.BGFX_RESET_VSYNC

bgfx = require('bgfx')

function init()

    bgfx.init()
    bgfx.reset( m_width, m_height, m_reset )

    bgfx.setDebug(m_debug)
    bgfx.setViewClear(0, bit.bor(bgfx.BGFX_CLEAR_COLOR, bgfx.BGFX_CLEAR_DEPTH), 0x303030ff, 1.0, 0)
end

function shutdown()
    bgfx.shutdown()
    return 0
end

function update()
    bgfx.setViewRect(0,0,0, m_width, m_height)
    bgfx.touch(0)
    
    bgfx.dbgTextClear()
    bgfx.dbgTextImage(   ((m_width /2 /8), 20) - 20,
                        ((m_height /2 /16), 6) - 6,
                        40, 12, s_logo, 160)
                        
    bgfx.dbgTextPrintf(0, 1, 0x4f, "bgfx/examples/00-helloworld")
    bgfx.dbgTextPrintf(0, 2, 0x6f, "Description: Initialization and debug text.")
    
    bgfx.dbgTextPrintf(0, 4, 0x0f, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.")

    local stats = bgfx.getStats()
    bgfx.dbgTextPrintf(0, 6, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
            , stats.width
            , stats.height
            , stats.textWidth
            , stats.textHeight)

    bgfx.frame()
end
-----------------------------------------------------------------------------------
