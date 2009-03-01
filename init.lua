---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local pairs = pairs
local ipairs = ipairs
local clients = clients
local table = table
local otable = otable
local awesome = awesome
local type = type
local capi = {
    hooks = hooks,
    screen = screen,
}

require("mediocre.screen")
require("mediocre.tag")
require("mediocre.group")
require("mediocre.client")
require("mediocre.layout")
require("mediocre.util")
require("mediocre.widget")

--- Mediocre replacement of the awful functions
module("mediocre")

Tag = tag.Tag

screens = screen.screens

function left()
    local t = screen():tag()
    t:prev()
    t:focus()
end

function right()
    local t = screen():tag()
    t:next()
    t:focus()
end

function down()
    local g = screen():tag():group()
    g:next()
    g:focus()
end

function up()
    local g = screen():tag():group()
    g:prev()
    g:focus()
end

function move_left()
    local t = screen():tag()
    t:move_prev()
    t:focus()
end

function move_right()
    local t = screen():tag()
    t:move_next()
    t:focus()
end

function move_up()
    local g = screen():tag():group()
    g:move_prev()
    g:focus()
end

function move_down()
    local g = screen():tag():group()
    g:move_next()
    g:focus()
end

function restart()
    local c = util.checkfile(awesome.conffile)

    if type(c) ~= "function" then
        return c
    end

    util.debug("Restarting...")
    awesome.restart()
end

function set_layout(l)
    local t = screen():tag()
    local g = t:group()
    local f = t:group(0)
    if g ~= f then
        g.layout = l
    end
    capi.hooks.arrange()(screen().screen)
end

-- FIXME this is a hack
local previous = otable()
function float_layer_toggle()
    local t = screen():tag()
    if t.current == 0 then
        -- go back to previous or 1
        local p = previous[t] or 1
        t.current = p
    else
        -- goto float layer
        previous[t] = t.current
        t.current=0
    end
    local c = t:group():client()
    if c then
        c:focus()
    else
        capi.hooks.arrange()(screen().screen)
    end
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80

