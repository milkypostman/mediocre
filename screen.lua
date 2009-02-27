---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local otable = otable
local table = table
local tostring = tostring
local setmetatable = setmetatable
local capi = {
    screen = screen
}

local hooks = require("mediocre.hooks")
local util = require("mediocre.util")

module("mediocre.screen")

screens = {}
local _current

Screen = util.class(function(klass, s)
    klass.tags = {}
    klass.current= 1
    klass.screen = s
end)

function Screen:tag(t)
    local t = t or self.current
    return self.tags[t]
end

function Screen:add(t)
    table.insert(self.tags, t)
    t.screen = self
    t.tag.screen = self.screen
    if #self.tags == 1 then
        t.tag.selected = true
    end
end

function Screen:goto(t)
    if not t then return end

    local cur = self.tags[self.current]
    local new = self.tags[t]
    if not new then
        return
    end

    self.current = t
    cur.tag.selected = false
    new.tag.selected = true
    local g = self:tag():group()
    if not g then return end
    local c = g:client()
    if not c then return end
    c:focus()
end


function current()
    return screens[_current]
end

local function arrange(s)
    local wa = capi.screen[s].workarea
    local tag = screens[s]:tag()
    tag:arrange(wa)
end

hooks.arrange.register(arrange)

-- initialize all the screens
for s = 1, capi.screen.count() do
    local x = {}
    screens[s] = Screen(s)
    if not _current then
        _current = s
    end
end

setmetatable(_M, {__call = current})

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
