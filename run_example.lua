
package.path = package.path..";examples/?.lua;examples/common/?.lua;lua/?.lua;lua/?/init.lua"
package.path = package.path..";deps/?.lua;deps/?/init.lua;deps/stream/?.lua;deps/tls/?.lua;deps/path/?.lua"

local pathJoin = require('luvi').path.join

local spath = require('path')
local apppath = spath.resolve('.')

p(apppath)

dofile( pathJoin(apppath, pathJoin("examples", args[2])) )
