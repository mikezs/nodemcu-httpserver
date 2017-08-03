-- httpserver-init.lua
-- Part of nodemcu-httpserver, launches the server.
-- Author: Marcos Kirsch

local conf = nil
if file.exists("httpserver-conf.lc") then
   conf = dofile("httpserver-conf.lc")
else
   conf = dofile("httpserver-conf.lua")
end
-- Function for starting the server.
-- If you compiled the mdns module, then it will also register with mDNS.
local startServer = function(ip)
   local conf = dofile('httpserver-conf.lc')
   if (dofile("httpserver.lc")(conf['general']['port'])) then
      print("nodemcu-httpserver running at:")
      print("   http://" .. ip .. ":" ..  conf['general']['port'])
      if (mdns) then
         mdns.register(conf['mdns']['hostname'], { description=conf['mdns']['description'], service="http", port=conf['general']['port'], location=conf['mdns']['location'] })
         print ('   http://' .. conf['mdns']['hostname'] .. '.local.:' .. conf['general']['port'])
      end
   end
   conf = nil
end

local currentIP = nil
if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then

   -- Connect to the WiFi access point and start server once connected.
   -- If the server loses connectivity, server will restart.
   wifi.sta.on("got_ip", function(event, info)
      print("Connected to WiFi Access Point. Got IP: " .. info["ip"])
      startServer(info["ip"])
	  currentIP = info["ip"]
      wifi.sta.on("disconnected", function(event, info)
         print("Lost connectivity! Restarting...")
		 currentIP = nil
         node.restart()
      end)
   end)

   -- What if after a while (30 seconds) we didn't connect? Restart and keep trying.
   local watchdogTimer = tmr.create()
   watchdogTimer:register(30000, tmr.ALARM_SINGLE, function (watchdogTimer)
      if (not currentIP) then currentIP = wifi.ap.getip() end
      if currentIP == nil then
         print("No IP after a while. Restarting...")
         node.restart()
      else
         --print("Successfully got IP. Good, no need to restart.")
         watchdogTimer:unregister()
      end
   end)
   watchdogTimer:start()


else

   startServer(conf.wifi.accessPoint.ip)

end
