
local bgfx = require('bgfx')
local ffi = require('ffi')

local utils = {}

local function readall(path)
  local f = io.open(path, 'rb')
  local ws = nil
  if f then
	  xs = f:read('*all')
	  f:close()
  end
  if xs == nil then p("Cannot find file:", path) end
  return xs
end

utils.shaderprog = function(vpath, fpath)
  local vs_f = readall(vpath)
  local fs_f = readall(fpath)
  local vs = bgfx.bgfx_create_shader(bgfx.bgfx_copy(ffi.cast('char *', vs_f), #vs_f))
  vs_f = nil
  local fs = bgfx.bgfx_create_shader(bgfx.bgfx_copy(ffi.cast('char *', fs_f), #fs_f))
  fs_f = nil
  local prog = bgfx.bgfx_create_program(vs, fs, false)
  bgfx.bgfx_destroy_shader(vs)
  vs = nil
  bgfx.bgfx_destroy_shader(fs)
  fs = nil
  return prog
end

utils.gentexture = function()
  -- generates a really really simple 128x128 texture
  local raw = ffi.new('char [?]', 128*128*4)
  for y=0,127 do
    for x=0,127 do
      local dst = (y*128+x)*4
      raw[dst+0] = x*2
      raw[dst+1] = y*2
      raw[dst+2] = 127
      raw[dst+3] = 255
    end
  end

  local bgfx_owned_mem = bgfx.bgfx_copy(raw, 128*128*4)
  raw = nil

  local tfmt = BGFX_TEXTURE_FORMAT_RGBA8

  local texturehandle = bgfx.bgfx_create_texture_2d(128, 128, false, 1, tfmt, BGFX_TEXTURE_NONE, bgfx_owned_mem)
  return texturehandle
end

_M = {}
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
  return mat
end

utils.matrixinit = function()
    local projMtx = _M.m4float()
    local viewMtx = _M.m4float()
    local mdlMtx = _M.m4float()
    return projMtx, viewMtx, mdlMtx
end

utils.makeortho = function( mtx, l, r, b, t, n, f )
    return _M.m4orthoMS(mtx, l, r, b, t, n, f)
end

return utils
