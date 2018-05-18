local ffi = require('ffi')

-- Setup the SDL Window and it returns a bgfx handle to use
local sdl = require('sdl2-setup')
local bgfx = require('bgfx-setup')
local utils = require('bgfx-utils')

local event = ffi.new('SDL_Event')
local sdltimer = nil


 local tvb = ffi.new('bgfx_transient_vertex_buffer_t[1]')

----------------------------------------------------------------------------
-- Declare a simple vertex type with a simple shader
local simpleprog = utils.shaderprog('examples/shaders/bin/glsl/simple.vs.bin', 'examples/shaders/bin/glsl/simple.fs.bin')
local simplevdecl = ffi.new('bgfx_vertex_decl_t[1]')
bgfx.bgfx_vertex_decl_begin(simplevdecl, BGFX_RENDERER_TYPE_NOOP)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_POSITION, 2, bgfx.BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_TEXCOORD0, 2, bgfx.BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_COLOR0, 4, bgfx.BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_end(simplevdecl)

-- Sampler color for texture mapping
local samplerColor = bgfx.bgfx_create_uniform('s_texColor', BGFX_UNIFORM_TYPE_INT1, 1)
local texture = utils.gentexture()

----------------------------------------------------------------------------


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

local http = require("http")
local https = require("https")
local pathJoin = require('luvi').path.join
local fs = require('fs')

local function onRequest(req, res)
    print(req.socket.options and "https" or "http", req.method, req.url)
    local body = "Hello world\n"
    res:setHeader("Content-Type", "text/plain")
    res:setHeader("Content-Length", #body)
    res:finish(body)
    
    shutdown()
end

http.createServer(onRequest):listen(8080)
print("Server listening at http://localhost:8080/")

https.createServer({
  key = fs.readFileSync( "key.pem"),
  cert = fs.readFileSync("cert.pem"),
}, onRequest):listen(8443)
print("Server listening at https://localhost:8443/")

timer = require('timer')
init()
sdltimer = timer.setInterval(20, update)

