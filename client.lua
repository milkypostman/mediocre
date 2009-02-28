---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

local otable = otable
local mouse = mouse
local table = table
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local type = type
local math = math
local setmetatable = setmetatable

local capi = {
    client = client
}

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
    local mt = {}
    mt.__index = function(obj, data)
        if data == "name" then
            return obj.client.name
        elseif data == "geometry" then
            return function(s, g)
                s.client:geometry(g)
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

function Client:focus()
    capi.client.focus = self.client
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
local focus = {enabled = false}
function focus.disable()
    focus.enabled = false
end
function focus.enable()
    focus.enabled = true
end
hooks.focus.register(focus.run)

function focus.run(c)
    if focus.enabled then
        util.debug("--Focus Function")
        focus.enabled = false
        local old = screen():tag():group():client()
        local cli = clients[c]

        local s = screen()
        local t = s:tag()

        for i, g in pairs(t.groups) do
            if cli.groups[g] then
                g:set(cli)
                if not old.groups[g] then
                    t:set(g)
                end
                break
            end
        end
        cli:focus()
    end
end
hooks.mouse_enter.register(focus.enable)

setmetatable(focus, {__call = function(_,c) focus.run(c) end})

local function manage(c, startup)
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
