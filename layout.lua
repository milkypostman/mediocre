---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------


local tag = tag
local ipairs = ipairs
local setmetatable = setmetatable

local util = require("mediocre.util")

module("mediocre.layout")

max = {}
max.name = "max"
function max.arrange(_, grp, g)
    for i,c in ipairs(grp.clients) do
        c:geometry(g)
        if i == grp.current then
            c:raise()
        end
    end
end
setmetatable(max, {__call = max.arrange})

divide = {}
divide.name = "divide"
function divide.arrange(_, grp, g)
    local height = g.height / #grp.clients
    g.height = height
    for i,c in ipairs(grp.clients) do
        c:geometry(g)
        if i == grp.current then
            c:raise()
        end
        g.y = g.y+height
    end
end
setmetatable(divide, {__call = divide.arrange})

floating = {}
floating.name = "floating"
function floating.arrange(_, grp, g)
    for i,c in ipairs(grp.clients) do
        util.debug("floating layout")
        if i == grp.current then
            c:raise()
        end
    end
end
setmetatable(floating, {__call = floating.arrange})


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
