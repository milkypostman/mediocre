---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------


local table = table
local clients = clients
local ipairs = ipairs

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
    self.current = (self.current % #self.clients) + 1
end

function Group:prev()
    self.current = ((self.current-2) % #self.clients) + 1
end

function Group:move_next()
    local idx = (self.current % #self.clients) + 1
    local c = table.remove(self.clients, self.current)
    table.insert(self.clients, idx, c)
    self.current = idx
end

function Group:move_prev()
    local idx = ((self.current-2) % #self.clients) + 1
    local c = table.remove(self.clients, self.current)
    table.insert(self.clients, idx, c)
    self.current = idx
end

function Group:add(c)
    table.insert(self.clients, self.current, c)
    c.groups[self] = true
    return self.current
end

function Group:set(cli)
    for i, c in ipairs(self.clients) do
        if cli == c then
            self.current = i
        end
    end
end

function Group:remove(c)
    if not c then
        local idx = self.current
        local c = self.clients[idx]
        c.groups[self] = nil

        table.remove(self.clients, self.current)
        if #self.clients and self.current > #self.clients then
            self.current = #self.clients
        end
    else
        for i,k in ipairs(self.clients) do
            if k == c then
                table.remove(self.clients, i)
                k.groups[self] = nil
                break
            end
        end
        if #self.clients and self.current > #self.clients then
            self.current = #self.clients
        end
    end
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
