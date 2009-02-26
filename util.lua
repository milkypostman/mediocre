---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurti@gmail.com&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @copyright 2008 Julien Danjou
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local setmetatable = setmetatable
local io = io
local loadfile = loadfile

--- Utility module for mediocre
module("mediocre.util")

-- simple class generator with no inheritance
function class(fn)
    local c = {}
    c.__index = c
    local mt = {}
    mt.__call = function(_, ...)
        local o = {}
        if fn then
            fn(o, ...)
        end
        setmetatable(o, c)
        return o
    end

    return setmetatable(c, mt)
end

function debug(text)
    io.stderr:write(text.."\n")
end

function checkfile(path)
    local f, e = loadfile(path)
    -- Return function if function, otherwise return error.
    if f then return f end
    return e
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
