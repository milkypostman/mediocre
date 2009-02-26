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

-- when we focus by client then we have to worry about getting our tree
-- structure pointing right again.  this should only happen when we focus by
-- mouse, or urgent.
focus = {enabled = true}
function focus.disable()
    focus.enabled = false
end
function focus.enable()
    focus.enabled = true
end
function focus.run(c)
    if focus.enabled then
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
        focus.enabled = true
    end
    focus.enabled=true
end
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
        local n = t.current
        if n == 0 then
            n = 1
        end
        cg = t:group(n)
    end
    if not cg then
        cg = group.Group(t)
        t:add(cg)
    end
    cg:add(client)

    capi.client.focus = c
end

local function unmanage(c)
    local cls = clients[c]
    for grp,v in pairs(cls.groups) do
        grp:remove(cls)
        if not grp.floating and #grp.clients == 0 then
            grp.tag:remove(grp)
        end
    end
    if c.transient_for then
        local cc = clients[c.transient_for]
        cc:focus()
    else
        screen():tag():group():client():focus()
    end
end

hooks.manage.register(manage)
hooks.unmanage.register(unmanage)
hooks.focus.register(focus.run)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
