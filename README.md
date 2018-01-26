# haproxy prometheus exporter written in Lua
A prometheus exporter embedded in HAProxy and written in Lua

This prometheus exporter exports statistics from internal HAProxy structures into the prometheus format.
It has been tested with the followiing combinations:
 * HAProxy 1.8 and Lua 5.3.2
 * HAProxy 1.9 and Lua 5.3.4

# installation / configuration
First, it requires an HAProxy version compiled with Lua :)
Then, simply put the file prometheus.lua close to your HAProxy configuration file and load it in the HAProxy's global section:
```
global
  [...]
  lua-load prometheus.lua
```

Then add a new http-request rule in the frontend to collect the metrics:
```
frontend fe_prometheus
  [...]
  http-request use-service lua.prometheus
```
