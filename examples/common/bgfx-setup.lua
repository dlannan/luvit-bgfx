

-- Always call this after the creation of the window.
local ffi = require 'ffi'
local bgfx = require('bgfx')
local win32 = require('user32')

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! Add some useful stuff the binding generator misses !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BGFX_STATE_BLEND_FUNC_SEPARATE = function(srcRGB, dstRGB, srcA, dstA)
return tonumber(srcRGB) + bit.lshift(tonumber(dstRGB), 4) + bit.lshift(tonumber(srcA) + bit.lshift(tonumber(dstA), 4), 8)
end
BGFX_STATE_BLEND_FUNC = function(src, dst)
return BGFX_STATE_BLEND_FUNC_SEPARATE(src, dst, src, dst)
end
BGFX_STATE_BLEND_NORMAL = BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_ONE, BGFX_STATE_BLEND_INV_SRC_ALPHA)
BGFX_STATE_BLEND_ALPHA = BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA)
BGFX_STATE_BLEND_MULTIPLY = BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_DST_COLOR, BGFX_STATE_BLEND_ZERO)

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

print('constructing platdata')
local pdparam =
{
  backBuffer = nil,
  backBufferDS = nil,
  ndt = nil,
  nwh = win32.GetActiveWindow(),
  context = nil
}

local pd = ffi.new('bgfx_platform_data_t', pdparam)

print('set platdata')
bgfx.bgfx_set_platform_data(pd)

-- yet another implicit but as-yet unloaded bgfx dependency
if wwos == 'linux' then
    -- What's a Vulkan?
    ffi.load('/usr/lib/libGL.so', true)
end

print('pre-init')
local renderer_type = BGFX_RENDERER_TYPE_OPENGL
bgfx.bgfx_init(renderer_type, 0, 0, nil, nil)
print('bgfx_reset')
bgfx.bgfx_reset(640, 400, BGFX_RESET_VSYNC)

print('bgfx_set_debug')
bgfx.bgfx_set_debug(BGFX_DEBUG_TEXT)

bgfx.bgfx_set_view_clear(0, BGFX_CLEAR_COLOR + BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)
bgfx.bgfx_set_view_rect(0, 0, 0, 640, 400)

return bgfx