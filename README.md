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
# Filtering output
This prometheus exporter can filter output. For this purpose, one can set query string parameters when calling the '/metrics' URL:
 * `backend`: return metrics for this backend only (including its servers)
 * `frontend`: return metrics for this frontend only
 * `metric`: return this metric only

The following rules applies:
 * if only `backend` or `frontend` is specified, then all frontends or backends will be returned respectively. To get returned metrics for a single backend, simply add a frontend parameter with a dummy value (null is ignored)
 * `backend` and `frontend` parameters can be passed multiple times. The exporter will then export metrics for all of them
 * `metric` must point to an HAProxy metric name. The exporter provides this metric name as part of the metric's HELP

Examples:
 * Get metrics for the two backends *be1* and *be2* and all frontends: "/metrics?backend=be1&backend=be2"
 * Get metrics for the two backends *be1* and *be2* only: "/metrics?backend=be1&backend=be2&frontend=NAN"
 * Get current number of current active sessions on frontend *fe_main*: "/metrics?frontend=fe_main&metric=scur"
