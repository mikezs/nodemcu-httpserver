-- httpserver-wifi.lua
-- Part of nodemcu-httpserver, configures NodeMCU's WiFI in boot.
-- Author: Marcos Kirsch

local conf = nil
if file.exists("httpserver-conf.lc") then
   conf = dofile("httpserver-conf.lc")
else
   conf = dofile("httpserver-conf.lua")
end

wifi.start()
wifi.mode(conf.wifi.mode)

if (conf.wifi.mode == wifi.SOFTAP) or (conf.wifi.mode == wifi.STATIONAP) then
    wifi.ap.config(conf.wifi.accessPoint.config)
    wifi.ap.setip(conf.wifi.accessPoint.ip)
end

if (conf.wifi.mode == wifi.STATION) or (conf.wifi.mode == wifi.STATIONAP) then
    wifi.sta.config(conf.wifi.station)
end

print('chip: ',node.chipid())
print('heap: ',node.heap())

conf = nil
collectgarbage()

-- End WiFi configuration
