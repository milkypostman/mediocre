---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local pairs = pairs
local ipairs = ipairs
local clients = clients
local table = table
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

function float_layer()
    local t = screen():tag()
    t.current=0
    capi.hooks.arrange()(screen().screen)
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80

