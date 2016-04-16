local server
local conn
local handlers = {}
handlers.get = {}
handlers.post = {}
luaSmallServer = {}

local getMethod, getURL, trim, sendNotFound

--HELPERS
function getMethod(payload)
    return trim(string.match(payload, "(%a%a%a%a?)%s"))
end
function getURL(payload)
    return trim(string.match(payload, "%a%a%a%a?%s(.*)HTTP"))
end
function trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end
function sendNotFound(conn)
    conn:send("HTTP/1.1 404 Not Found\n")
    conn:send("Server: NodeMCU\n")
    conn:send("\n")
    conn:on("sent", function(conn) conn:close() end)
end

function sendOK(conn, payload, opts)
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("Server: NodeMCU\n")
    if payload ~=nil then
        conn:send("Content-Length: "..string.len(payload).."\n")
    end
    if opts ~= nil and opts.contentType ~=nil then
        conn:send("Content-Type: "..opts.contentType.."\n")
    end
    conn:send("\n")
    conn:send(payload)
    conn:on("sent", function(conn) conn:close() end)
end

luaSmallServer.create = function (type)
    server = net.createServer(type) 
    print ("Hello World!")
    
    return luaSmallServer;
end

luaSmallServer.listen = function (port, cb)
    server:listen(port, function (conn)
        conn:on("receive", function(conn,payload)
            hasMatch = false
            opr = getMethod(payload)
            url = getURL(payload)
            if opr == "GET" then
                for i = 1, #handlers.get do
                    if handlers.get[i].url == url then
                        hasMatch = true
                        handlers.get[i].cb(conn, payload)
                    end
                end
            elseif opr == "POST" then
                for i = 1, #handlers.post do
                    if handlers.post[i].url == url then
                        hasMatch = true
                        handlers.post[i].cb(conn, payload)
                    end
                end
            end
            if not hasMatch then
                sendNotFound(conn)
            end
        end)
        cb(conn)
    end)
    return luaSmallServer;
end

luaSmallServer.get = function (url, cb)
    table.insert(handlers.get, {
        url = url,
        cb = cb
    })
    return luaSmallServer
end

luaSmallServer.post = function (url, cb)
    table.insert(handlers.post, {
        url = url,
        cb = cb
    })
    return luaSmallServer
end

luaSmallServer.sendNotFound = sendNotFound
luaSmallServer.sendOK = sendOK
