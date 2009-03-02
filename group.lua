---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------


local table = table
local clients = clients

local util = require("mediocre.util")
local layout = require("mediocre.layout")

module("mediocre.group")


Group = util.class(function(klass, t, l)
    klass.tag = t
    klass.clients = {}
    klass.current = 1
    klass.layout = l or layout.max
end)

function Group:client()
    local c = self.clients[self.current]
    return self.clients[self.current]
end

function Group:next()
    if #self.clients < 1 then return end
    self.current = (self.current % #self.clients) + 1
end

function Group:prev()
    if #self.clients < 1 then return end
    self.current = ((self.current-2) % #self.clients) + 1
end

function Group:move_next()
    local idx = (self.current % #self.clients) + 1
    local c = self.clients[self.current]
    if idx == 1 then
        self:remove(c)
        self:add(c, idx)
    else
        self:swap_by_idx(self.current, idx)
    end
    self.current = idx
end

function Group:swap_by_idx(c1, c2)
    local cli1 = self.clients[c1]
    local cli2 = self.clients[c2]

    self.clients[c1] = cli2
    self.clients[c2] = cli1

    cli1.groups[self] = c2
    cli2.groups[self] = c1
end

function Group:move_prev()
    local idx = ((self.current-2) % #self.clients) + 1
    local c = self.clients[self.current]
    if idx == #self.clients then
        self:remove(c)
        self:add(c, idx)
    else
        self:swap_by_idx(self.current, idx)
    end
    self.current = idx
end

function Group:add(c, idx)
    local idx = idx or self.current
    for i = #self.clients, idx, -1 do
        local cli = self.clients[i]
        cli.groups[self] = i+1
        self.clients[i+1] = cli
    end
    self.clients[idx] = c
    c.groups[self] = idx
    --table.insert(self.clients, self.current, c)
end

function Group:set(cli)
    self.current = cli.groups[self]
end

function Group:focus()
    local c = self:client()
    if not c then return end
    c:focus()
end

function Group:remove(c)
    local c = c or self.clients[self.current]
    if not c or not c.groups[self] then return end

    for i = c.groups[self], #self.clients-1 do
        local cli = self.clients[i+1]
        cli.groups[self] = i
        self.clients[i] = cli
    end
    self.clients[#self.clients] = nil
    c.groups[self] = nil

    if #self.clients > 0 and self.current > #self.clients then
        self.current = #self.clients
    end

    if  #self.clients == 0 and self.tagidx ~= 0 and (self.tagidx ~= 1 or #self.tag.groups >1) then
        self.tag:remove(self)
    end
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
