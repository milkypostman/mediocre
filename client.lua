---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local otable = otable
local mouse = mouse
local table = table
local pairs = pairs
local tostring = tostring
local type = type
local math = math
local setmetatable = setmetatable

local capi = {
    client = client,
    widget = widget,
    wibox = wibox,
}

local beautiful = require("beautiful")
local hooks = require("mediocre.hooks")
local util = require("mediocre.util")
local group = require("mediocre.group")
local screen = require("mediocre.screen")

module("mediocre.client")

local clients = otable()

-- Client is a special class that provides some
-- functions of the underlying C object
Client = {}
setmetatable(Client, {__call= function(_, c)
    local o = {}
    o.groups = {}
    o.client = c
    o.titlebar = nil
    local mt = {}
    mt.__index = function(obj, data)
        if data == "name" then
            return obj.client.name
        elseif data == "geometry" then
            return function(s, g)
                if g then
                    return s.client:geometry(g)
                else
                    return s.client:geometry()
                end
            end
        elseif data == "raise" then
            return function(s)
                s.client:raise()
            end
        else
            return Client[data]
        end
    end

    setmetatable(o, mt)
    return o
end
})

-- internal simply says that we don't need to reassign the capi client
function Client:focus(internal)
    if not internal then
        capi.client.focus = self.client
    elseif self.titlebar then
        self.titlebar.fg = beautiful.titlebar_fg_focus or beautiful.fg_focus
        self.titlebar.bg = beautiful.titlebar_bg_focus or beautiful.bg_focus
        --self.titlebar.border_width = beautiful.border_width
        self.titlebar.border_color = beautiful.border_focus
    end
end

function Client:unfocus(internal)
    if internal and self.titlebar then
        self.titlebar.fg = beautiful.titlebar_fg_normal or beautiful.fg_normal
        self.titlebar.bg = beautiful.titlebar_bg_normal or beautiful.bg_normal
        --self.titlebar.border_width = beautiful.border_width
        self.titlebar.border_color = beautiful.border_normal
    end
end

function Client:set_titlebar(enabled)
    if enabled == true and not self.titlebar then
        util.debug("setting up titlebar")
        if self.client.type ~= 'normal' and self.client.type ~= 'dialog' then return end
        util.debug("setting up titlebar")
        local theme = beautiful.get()
        local tb = capi.wibox({})

        local title = capi.widget({type='textbox', align='flex'})
        title.text = ' '..util.escape(self.client.name)..' '

        local appicon = capi.widget({ type = "imagebox", align = "left" })
        appicon.image = self.client.icon

        tb.widgets = {appicon = appicon, title = title}
        self.client.titlebar = tb
        self.titlebar = tb

        tb.fg = beautiful.fg_focus
        tb.bg = beautiful.bg_focus
        tb.border_width = beautiful.border_width
        tb.border_color = beautiful.border_focus

        self.client:geometry(self.client:geometry())
    elseif enabled == false and self.titlebar then
        self.client.titlebar = nil
        self.titlebar = nil
    end
end

function Client:update(prop)
    if self.titlebar then
        local widgets = self.titlebar.widgets
        if prop == 'name' then
            widgets.title.text = ' '..util.escape(self.client.name)..' '
        end
    end
end

function Client:orphan()
    for grp,v in pairs(self.groups) do
        grp:remove(self)
    end
    self.client:tags({})
end

function Client:move(t)
    local s = screen()
    local ot = s:tag()
    local nt = s:tag(t)
    if not ot or not nt then return end

    -- remove from all groups
    self:orphan()

    local cg
    local n = math.min(ot.current, 1)
    local cg = nt:group(n)
    if not cg then
        util.debug("creating group")
        cg = group.Group(nt)
        nt:add(cg)
    end
    cg:add(self)
    self.client:tags({nt.tag})

    local g = ot:group()
    if not g then return end
    local c = g:client()
    if not c then return end
    c:focus()
end

-- when we focus by client then we have to worry about getting our tree
-- structure pointing right again.  this should only happen when we focus by
-- mouse, or urgent.
local mouse_enter = false

local function focus(c)
    local cli = clients[c]
    if cli then
        local s = screen()
        local t = s:tag()

        for i, g in pairs(t.groups) do
            if cli.groups[g] then
                g:set(cli)
                t:set(g)
                break
            end
        end
        cli:focus(true)
    end
end

local function unfocus(c)
    local cli = clients[c]
    if cli then
        cli:unfocus(true)
    end
end

local function update(c, prop)
    local cli = clients[c]
    if cli then
        cli:update(prop)
    end
end


hooks.focus.register(focus)
hooks.unfocus.register(unfocus)
hooks.property.register(update)
hooks.mouse_enter.register(function() mouse_enter = true end)

local function manage(c, startup)
    if c.sticky == true then return end
    local s = screen.current()

    local t = s:tag()
    c:tags({t.tag})
    c.size_hints_honor = false
    client = Client(c)
    if not clients[c] then
        clients[c] = client
    end
    local cg
    if c.type ~= "normal" then
        cg = t:group(0)
    else
        cg = t:group()
    end
    if not cg then
        util.debug("creating group")
        cg = group.Group(t)
        t:add(cg)
    end
    cg:add(client)

    capi.client.focus = c
end
hooks.manage.register(manage)

local function unmanage(c)
    local cls = clients[c]
    cls:orphan()
    if c.transient_for then
        local cc = clients[c.transient_for]
        cc:focus()
    else
        screen():tag():focus()
    end
end

hooks.unmanage.register(unmanage)

function lookup(c)
    return clients[c]
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
