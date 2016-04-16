require("lua-small-server")

wifi.setmode(wifi.STATION)
wifi.sta.config("Hazard", "Razor1911")
ip = wifi.sta.getip()
print(ip)

server = luaSmallServer.create(net.TCP)

server.listen(80, function()
    print('server created')
end).get('/', function (conn,payload)
    luaSmallServer.sendOK(conn, "<h1> Hello, NodeMCU.</h1>", {contentType = "text/html"})
end)

server.get('/ap', function (conn,payload)
    wifi.sta.getap(1, function (aps)
        luaSmallServer.sendOK(conn, cjson.encode(parseAPs(aps)), {contentType = "application/json"})
    end)
end)

server.get('/ap/hidden', function (conn,payload)
    wifi.sta.getap({show_hidden = 1 }, 1, function (aps)
        luaSmallServer.sendOK(conn, cjson.encode(parseAPs(aps)), {contentType = "application/json"})
    end)
end)

function parseAPs(aps) -- (SSID : Authmode, RSSI, BSSID, Channel)
    list = {}
    for bssid,v in pairs(aps) do
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        table.insert(list, {
            ssid = string.format("%32s",ssid),
            bssid = bssid,
            rssi = rssi,
            authmode = authmode,
            channel = channel            
        })
    end
    return list
end
