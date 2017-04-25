
local ffi = require('ffi')
ffi.cdef [[
void *                       GetActiveWindow(                    );
]]
return ffi.load( 'User32.dll' )