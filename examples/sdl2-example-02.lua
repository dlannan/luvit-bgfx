local ffi = require('ffi')

-- Setup the SDL Window and it returns a bgfx handle to use
local sdl = require('sdl2-setup')
local bgfx = require('bgfx-setup')
local utils = require('bgfx-utils')

local event = ffi.new('SDL_Event')


local w = 640
local h = 400
local whChanged = true

-- with apologies to https://github.com/pixeljetstream/luajit_gfx_sandbox/blob/master/runtime/lua/math3d.lua


local simpleprog = utils.shaderprog('examples/shaders/bin/glsl/simple.vs.bin', 'examples/shaders/bin/glsl/simple.fs.bin')
local simplevdecl = ffi.new('bgfx_vertex_decl_t[1]')
bgfx.bgfx_vertex_decl_begin(simplevdecl, BGFX_RENDERER_TYPE_NOOP)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_POSITION, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_add(simplevdecl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_FLOAT, false, false)
bgfx.bgfx_vertex_decl_end(simplevdecl)
local samplerColor = bgfx.bgfx_create_uniform('s_texColor', BGFX_UNIFORM_TYPE_INT1, 1)

local texture = utils.gentexture()

local _M = {}
function _M.m4float()
  local m = ffi.new('float[16]')
  for i = 0,15 do m[i] = 0 end
  m[0] = 1
  m[5] = 1
  m[10] = 1
  m[15] = 1
  return m
end

function _M.m4orthoMS(mat, left, right, bottom, top, near, far)
  -- NOTE: assumes matrix 'mat' is identity!
  mat[0] = 2.0/(right-left)
  mat[5] = 2.0/(top-bottom)
  mat[10] = 1.0/(near-far)
  mat[12] = (left + right)/(left - right)
  mat[13] = (top + bottom)/(bottom - top)
  mat[14] = near / (near - far)
  mat[15] = 1.0
end

local projMtx = _M.m4float()
local viewMtx = _M.m4float()
local mdlMtx = _M.m4float()

local verts = {}
local function pushv(x, y, u, v, r, g, b, a)
  verts[#verts+1] = x
  verts[#verts+1] = y
  verts[#verts+1] = u
  verts[#verts+1] = v
  verts[#verts+1] = r
  verts[#verts+1] = g
  verts[#verts+1] = b
  verts[#verts+1] = a
end
local function pushquad(x, y, w, h)
  pushv(x, y,     0, 0,    1, 1, 1, 1)
  pushv(x, y+h,   0, 1,    1, 1, 1, 1)
  pushv(x+w, y,   1, 0,    1, 1, 1, 1)
  pushv(x+w, y,   1, 0,    1, 1, 1, 1)
  pushv(x, y+h,   0, 1,    1, 1, 1, 1)
  pushv(x+w, y+h, 1, 1,    1, 1, 1, 1)
end

pushquad(100, 100, 128, 128)

local running = true

local function MainRenderLoop( )

  if whChanged then
    bgfx.bgfx_reset(w, h, BGFX_RESET_VSYNC)
    bgfx.bgfx_set_view_rect(0, 0, 0, w, h)
    _M.m4orthoMS(projMtx, 0, w, h, 0, 0, 2)
    whChanged = false
  end

  bgfx.bgfx_set_view_seq(0, true)
  bgfx.bgfx_set_view_transform(0, viewMtx, projMtx)

  -- hey, i never said it was a well-written example. i'm cribbing from my own code here.
  local tvb = ffi.new('bgfx_transient_vertex_buffer_t[1]')
  local numverts = #verts/8
  bgfx.bgfx_alloc_transient_vertex_buffer(tvb, numverts, simplevdecl)
  local vdptr = ffi.cast('float *', tvb[0].data)
  for i = 1,#verts do
    vdptr[i-1] = verts[i]
  end

  bgfx.bgfx_set_transform(mdlMtx, 1)
  bgfx.bgfx_set_state(BGFX_STATE_BLEND_ALPHA + BGFX_STATE_ALPHA_WRITE + BGFX_STATE_DEPTH_WRITE + BGFX_STATE_RGB_WRITE, 0xffffffff)
  bgfx.bgfx_set_transient_vertex_buffer(tvb, 0, #verts/8)
  -- texture unit 0
  bgfx.bgfx_set_texture(0, samplerColor, texture, 0xffffffff)
  bgfx.bgfx_submit(0, simpleprog, 0, false)

  bgfx.bgfx_touch(0)
  bgfx.bgfx_dbg_text_clear(0, false)
  bgfx.bgfx_dbg_text_printf(0, 1, 0x4f, 'Hi there!')

  bgfx.bgfx_frame(false)

    while sdl.pollEvent(event) ~= 0 do
      if event.type == sdl.QUIT then
         running = false
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
    
    bgfx.bgfx_shutdown()
    sdl.destroyWindow(window)
    sdl.quit()
end

http.createServer(onRequest):listen(8080)
print("Server listening at http://localhost:8080/")

https.createServer({
  key = fs.readFileSync( "key.pem"),
  cert = fs.readFileSync( "cert.pem"),
}, onRequest):listen(8443)
print("Server listening at https://localhost:8443/")

timer = require('timer')
timer.setInterval(20, MainRenderLoop)

