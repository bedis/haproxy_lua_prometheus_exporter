--[[
The MIT license

Copyright 2018 bedis9@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]


-- functions dedicated to transform some HAProxy metric value into something
-- prometheus can consume natively
-- NOTE: those type of functions must be written BEFORE the global tables
--       which describe the HAProxy metrics (frontendMetrics, ...)

-- function which returns an integer related to the string which describes
-- a frontend or backend or server status
function parseStatusField(status)
  if status:sub(1,2) == 'UP' or status == 'OPEN' or status == 'no check' then
    return 1
  end
  return 0
end

-- function which turns ms to s, because prometheus expects seconds
function ms2s(nb)
  return nb / 1000
end



-- default page served when the request arrive in the Lua exporter
-- for any URL but /metrics
default_page = [[
<html>
<head><title>Haproxy Exporter in Lua</title></head>
<body>
<h1>Haproxy Exporter in Lua</h1>
<p><a href='/metrics'>Metrics</a></p>
</body>
</html>
]]

-- table to link HAProxy's frontend statistics counter to its prometheus equivalent
frontendMetrics = {
	scur = { type="gauge", metricName="haproxy_frontend_current_sessions", help="Current number of active sessions." };
	smax = { type="gauge", metricName="haproxy_frontend_max_sessions", help="Maximum observed number of active sessions." };
	slim = { type="gauge", metricName="haproxy_frontend_limit_sessions", help="Configured session limit." };
	stot = { type="gauge", metricName="haproxy_frontend_sessions_total", help="Total number of sessions." };
	bin = { type="gauge", metricName="haproxy_frontend_bytes_in_total", help="Current total of incoming bytes." };
	bout = { type="gauge", metricName="haproxy_frontend_bytes_out_total", help="Current total of outgoing bytes." };
	dreq = { type="gauge", metricName="haproxy_frontend_requests_denied_total", help="Total of requests denied for security." };
	ereq = { type="gauge", metricName="haproxy_frontend_request_errors_total", help="Total of request errors." };
	rate = { type="gauge", metricName="haproxy_frontend_current_session_rate", help="Current number of sessions per second over last elapsed second." };
	rate_lim = { type="gauge", metricName="haproxy_frontend_limit_session_rate", help="Configured limit on new sessions per second." };
	rate_max = { type="gauge", metricName="haproxy_frontend_max_session_rate", help="Maximum observed number of sessions per second." };
	hrsp_1xx = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='1xx' }, };
	hrsp_2xx = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='2xx' }, };
	hrsp_3xx = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='3xx' }, };
	hrsp_4xx = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='4xx' }, };
	hrsp_5xx = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='5xx' }, };
	hrsp_other = { type="gauge", metricName="haproxy_frontend_http_responses_total", help="Total of HTTP responses.", labels={ code='other' }, };
	req_tot = { type="gauge", metricName="haproxy_frontend_http_requests_total", help="Total HTTP requests." };
	conn_tot = { type="gauge", metricName="haproxy_frontend_connections_total", help="Total number of connections" };
}

-- table to link HAProxy's backend statistics counter to its prometheus equivalent
backendMetrics = {
	qcur = { type="gauge", metricName="haproxy_backend_current_queue", help="Current number of queued requests not assigned to any server." };
	qmax = { type="gauge", metricName="haproxy_backend_max_queue", help="Maximum observed number of queued requests not assigned to any server." };
	scur = { type="gauge", metricName="haproxy_backend_current_sessions", help="Current number of active sessions." };
	smax = { type="gauge", metricName="haproxy_backend_max_sessions", help="Maximum observed number of active sessions." };
	slim = { type="gauge", metricName="haproxy_backend_limit_sessions", help="Configured session limit." };
	stot = { type="gauge", metricName="haproxy_backend_sessions_total", help="Total number of sessions." };
	bin = { type="gauge", metricName="haproxy_backend_bytes_in_total", help="Current total of incoming bytes." };
	bout = { type="gauge", metricName="haproxy_backend_bytes_out_total", help="Current total of outgoing bytes." };
	econ = { type="gauge", metricName="haproxy_backend_connection_errors_total", help="Total of connection errors." };
	eresp = { type="gauge", metricName="haproxy_backend_response_errors_total", help="Total of response errors." };
	wretr = { type="gauge", metricName="haproxy_backend_retry_warnings_total", help="Total of retry warnings." };
	wredis = { type="gauge", metricName="haproxy_backend_redispatch_warnings_total", help="Total of redispatch warnings." };
	status = { type="gauge", metricName="haproxy_backend_up", help="Current health status of the backend (1 = UP, 0 = DOWN).", transform=parseStatusField };
	weight = { type="gauge", metricName="haproxy_backend_weight", help="Total weight of the servers in the backend." };
	act = { type="gauge", metricName="haproxy_backend_current_server", help="Current number of active servers" };
	rate = { type="gauge", metricName="haproxy_backend_current_session_rate", help="Current number of sessions per second over last elapsed second." };
	rate_max = { type="gauge", metricName="haproxy_backend_max_session_rate", help="Maximum number of sessions per second." };
	hrsp_1xx = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='1xx' } };
	hrsp_2xx = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='2xx' } };
	hrsp_3xx = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='3xx' } };
	hrsp_4xx = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='4xx' } };
	hrsp_5xx = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='5xx' } };
	hrsp_other = { type="gauge", metricName="haproxy_backend_http_responses_total", help="Total of HTTP responses.", labels={ code='other' } };
	queue = { type="gauge", metricName="haproxy_backend_http_queue_time_average_seconds", help="Avg. HTTP queue time for last 1024 successful connections.", transform=ms2s };
	ctime = { type="gauge", metricName="haproxy_backend_http_connect_time_average_seconds", help="Avg. HTTP connect time for last 1024 successful connections.", transform=ms2s };
	rtime = { type="gauge", metricName="haproxy_backend_http_response_time_average_seconds", help="Avg. HTTP response time for last 1024 successful connections.", transform=ms2s };
	ttime = { type="gauge", metricName="haproxy_backend_http_total_time_average_seconds", help="Avg. HTTP total time for last 1024 successful connections.", transform=ms2s };
}

-- table to link HAProxy's server statistics counter to its prometheus equivalent
serverMetrics = {
	qcur = { type="gauge", metricName="haproxy_server_current_queue", help="Current number of queued requests assigned to this server." };
	qmax = { type="gauge", metricName="haproxy_server_max_queue", help="Maximum observed number of queued requests assigned to this server.", };
	scur = { type="gauge", metricName="haproxy_server_current_sessions", help="Current number of active sessions." };
	smax = { type="gauge", metricName="haproxy_server_max_sessions", help="Maximum observed number of active sessions." };
	slim = { type="gauge", metricName="haproxy_server_limit_sessions", help="Configured session limit." };
	stot = { type="gauge", metricName="haproxy_server_sessions_total", help="Total number of sessions." };
	bin = { type="gauge", metricName="haproxy_server_bytes_in_total", help="Current total of incoming bytes." };
	bout = { type="gauge", metricName="haproxy_server_bytes_out_total", help="Current total of outgoing bytes." };
	econ = { type="gauge", metricName="haproxy_server_connection_errors_total", help="Total of connection errors." };
	eresp = { type="gauge", metricName="haproxy_server_response_errors_total", help="Total of response errors." };
	wretr = { type="gauge", metricName="haproxy_server_retry_warnings_total", help="Total of retry warnings." };
	wredis = { type="gauge", metricName="haproxy_server_redispatch_warnings_total", help="Total of redispatch warnings." };
	status = { type="gauge", metricName="haproxy_server_up", help="Current health status of the server (1 = UP, 0 = DOWN).", transform=parseStatusField };
	weight = { type="gauge", metricName="haproxy_server_weight", help="Current weight of the server." };
	chkfail = { type="gauge", metricName="haproxy_server_check_failures_total", help="Total number of failed health checks." };
	downtime = { type="gauge", metricName="haproxy_server_downtime_seconds_total", help="Total downtime in seconds." };
	rate = { type="gauge", metricName="haproxy_server_current_session_rate", help="Current number of sessions per second over last elapsed second." };
	rate_max = { type="gauge", metricName="haproxy_server_max_session_rate", help="Maximum observed number of sessions per second." };
	check_duration = { type="gauge", metricName="haproxy_server_check_duration_milliseconds", help="Previously run health check duration, in milliseconds" };
	hrsp_1xx = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='1xx' } };
	hrsp_2xx = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='2xx' } };
	hrsp_3xx = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='3xx' } };
	hrsp_4xx = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='4xx' } };
	hrsp_5xx = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='5xx' } };
	hrsp_other = { type="gauge", metricName="haproxy_server_http_responses_total", help="Total of HTTP responses.", labels={ code='other' } };
	queue = { type="gauge", metricName="haproxy_server_http_queue_time_average_seconds", help="Avg. HTTP queue time for last 1024 successful connections.", transform=ms2s  };
	ctime = { type="gauge", metricName="haproxy_server_http_connect_time_average_seconds", help="Avg. HTTP connect time for last 1024 successful connections.", transform=ms2s  };
	rtime = { type="gauge", metricName="haproxy_server_http_response_time_average_seconds", help="Avg. HTTP response time for last 1024 successful connections.", transform=ms2s  };
	ttime = { type="gauge", metricName="haproxy_server_http_total_time_average_seconds", help="Avg. HTTP total time for last 1024 successful connections.", transform=ms2s  };
}


-- prepare the global table which will hosts the metrics later
-- this function will be executed by HAProxy right after the full configuration parsing
-- and before runtime
metrics = {}
function load_metrics()
  for haproxyMetricName, metric in pairs(frontendMetrics)
  do
    local metricName = metric['metricName']
    local metricHelp = '# HELP ' .. metricName .. ' ' .. metric['help'] .. ' (' .. haproxyMetricName .. ')'
    local metricType = '# TYPE ' .. metricName .. ' ' .. metric['type']
    if not metrics[metricName] then
      metrics[metricName] = { help=metricHelp, type=metricType, objectType='frontend', values={} }
    end
  end

  for haproxyMetricName, metric in pairs(backendMetrics)
  do
    local metricName = metric['metricName']
    local metricHelp = '# HELP ' .. metricName .. ' ' .. metric['help'] .. ' (' .. haproxyMetricName .. ')'
    local metricType = '# TYPE ' .. metricName .. ' ' .. metric['type']
    if not metrics[metricName] then
      metrics[metricName] = { help=metricHelp, type=metricType, objectType='backend', values={} }
    end
  end
  for haproxyMetricName, metric in pairs(serverMetrics)
  do
    local metricName = metric['metricName']
    local metricHelp = '# HELP ' .. metricName .. ' ' .. metric['help'] .. ' (' .. haproxyMetricName .. ')'
    local metricType = '# TYPE ' .. metricName .. ' ' .. metric['type']
    if not metrics[metricName] then
      metrics[metricName] = { help=metricHelp, type=metricType, objectType='server', values={} }
    end
  end
end
core.register_init(load_metrics)


-- TODO comment
function load_frontend(myMetrics, feName, myStats, statsFilter)
  local myMetricsTable
  if statsFilter ~= nil then
    myMetricsTable = statsFilter
  else
    myMetricsTable = myStats
  end

  for haproxyMetricName,_ in pairs(myMetricsTable) do
    local metricName = ''
    if frontendMetrics[haproxyMetricName] then
      metricName = frontendMetrics[haproxyMetricName]['metricName']
    end
    -- Store the metrics in the global table
    if myMetrics[metricName] then
      local value = myStats[haproxyMetricName]
      local myValue = { name=feName, value=value }
      if frontendMetrics[haproxyMetricName]['labels'] then
        myValue['labels'] = frontendMetrics[haproxyMetricName]['labels']
      end
      table.insert(myMetrics[metricName]['values'], myValue)
    end
  end
end


-- TODO comment
function load_backend(myMetrics, beName, myStats, statsFilter)
  local myMetricsTable
  if statsFilter ~= nil then
    myMetricsTable = statsFilter
  else
    myMetricsTable = myStats
  end

  for haproxyMetricName,_ in pairs(myMetricsTable) do
    local metricName = ''
    if backendMetrics[haproxyMetricName] then
      metricName = backendMetrics[haproxyMetricName]['metricName']
    end
    -- Store the backend metrics in the global table
    if myMetrics[metricName] then
      local value = myStats[haproxyMetricName]

      if backendMetrics[haproxyMetricName].transform ~= nil then
        value = backendMetrics[haproxyMetricName].transform(value)
      end

      local myValue = { name=beName, value=value }
      if backendMetrics[haproxyMetricName]['labels'] then
        myValue['labels'] = backendMetrics[haproxyMetricName]['labels']
      end
      table.insert(myMetrics[metricName]['values'], myValue)
    end
  end
  -- server metrics
  -- haproxy_server_bytes_in_total{backend="be",server="node_exporter"} 0
  for k,s in pairs(core.backends[beName].servers) do
    local serverName = k
    local myStats = s.get_stats(s)
    local myMetricsTable
    if statsFilter ~= nil then
      myMetricsTable = statsFilter
    else
      myMetricsTable = myStats
    end

    for haproxyMetricName,_ in pairs(myMetricsTable) do
      local metricName = ''
      if serverMetrics[haproxyMetricName] then
        metricName = serverMetrics[haproxyMetricName]['metricName']
      end
      -- Store the server metrics in the global table
      if myMetrics[metricName] then
        local value = myStats[haproxyMetricName]

        if serverMetrics[haproxyMetricName].transform ~= nil then
          value = serverMetrics[haproxyMetricName].transform(value)
        end

        local myValue = { backend=beName, name=serverName, value=value }
        if serverMetrics[haproxyMetricName]['labels'] then
          myValue['labels'] = serverMetrics[haproxyMetricName]['labels']
        end
        table.insert(myMetrics[metricName]['values'], myValue)
      end
    end
  end
end

-- function which returns an HTTP response
--  <applet>: the HAProxy applet to use to send the response
--  <status>: HTTP status code
--  <body>: HTTP response body
function return_content(applet, status, body)
  -- send the response with the metrics
  applet:set_status(status)
  local len = string.len(body)
  applet:add_header("Content-Length", len)
  applet:add_header("Content-Type", "text/plain; version=0.0.4")
  --- TODO: Add date header
  applet:start_response()
  applet:send(body)
end

-- this is the service that one should call in HAProxy to export the metrics
-- into the prometheus format
-- To add it, you need to load this file in HAProxy's global section:
--   global
--     [...]
--     lua-load prometheus.lua
-- Then to add a http-request rule in a frontend:
--   frontend fe_prometheus
--     [...]
--     http-request use-service lua.prometheus
--
-- The only URL we would take care is for now is '/metrics'
--
core.register_service("prometheus", "http", function(applet)
  local method = applet.method
  local path   = applet.path
  local myMetrics = metrics

  if path ~= '/metrics' then
    applet:set_status(200)
    len = string.len(default_page)
    applet:add_header("Content-Length", len)
    applet:add_header("Content-Type", "text/html; charset=utf-8")
    --- TODO: Add date header
    applet:start_response()
    applet:send(default_page)
  end

  local buffer = core.concat()

  -- clean up old values first
  for name, metric in pairs(myMetrics)
  do
    metric['values'] = {}
  end

  -- analyze the query string
  --local filter = { enable = false;  backend = {}; frontend = {}; metric = {}; }
  local filter = {}
  local queryParameters = core.tokenize(applet.qs, "&")
  for _, param in pairs(queryParameters) do
    local tmp = core.tokenize(param, "=")
    if #tmp == 2 and #tmp[2] > 0 and (tmp[1] == 'backend' or tmp[1] == 'frontend' or tmp[1] == 'metric') then
      --FIXME: check the backend/frontend/metric exists here
      if filter[tmp[1]] == nil then
        filter[tmp[1]] = {}
      end
      filter[tmp[1]][tmp[2]] = true
    end
  end

  -- filling up the global table with the frontend metrics
  -- First parses HAProxy's internal structure
  local myFrontendTable = nil
  if filter.frontend ~= nil then
    myFrontendTable = filter.frontend
  else
    myFrontendTable = core.frontends
  end
  if myFrontendTable ~= nil then
    for j,_ in pairs(myFrontendTable) do
      local f = core.frontends[j]
      if f == nil then goto continue end
      local myStats = f.get_stats(f)
      load_frontend(myMetrics, f.name, myStats, filter.metric)
      ::continue::
    end
  end


  -- filling up the global table with the backend and server metrics
  -- First parses HAProxy's internal structure
  local myBackendTable = nil
  if filter.backend ~= nil then
    myBackendTable = filter.backend
  else
    myBackendTable = core.backends
  end
  if myBackendTable ~= nil then
    for j,_ in pairs(myBackendTable) do
      local b = core.backends[j]
      if b == nil then goto continue end
      local myStats = b.get_stats(b)
      load_backend(myMetrics, b.name, myStats, filter.metric)
      ::continue::
    end
  end

  -- prepare the body of the response
  for metricName, metric in pairs(myMetrics)
  do
    if #metric['values'] > 0 then
      buffer:add(metric['help'])
      buffer:add('\n')
      buffer:add(metric['type'])
      buffer:add('\n')
      for id, line in pairs(metric['values'])
      do
        buffer:add(metricName)
        if metric['objectType'] == 'server' then
          buffer:add('{backend="')
          buffer:add(line['backend'])
          buffer:add('",')
          buffer:add(metric['objectType'])
          buffer:add('="')
          buffer:add(line['name'])
          buffer:add('"')
        else
          buffer:add('{')
          buffer:add(metric['objectType'])
          buffer:add('="')
          buffer:add(line['name'])
          buffer:add('"')
        end
        if line['labels'] then
          for labelName, labelValue in pairs(line['labels'])
          do
            buffer:add(',')
            buffer:add(labelName)
            buffer:add('="')
            buffer:add(labelValue)
            buffer:add('"')
          end
        end
        buffer:add('} ')
        buffer:add(line['value'])
        buffer:add('\n')
      end
    end
  end

  -- send the response with the metrics
  applet:set_status(200)
  len = string.len(buffer:dump())
  applet:add_header("Content-Length", len)
  applet:add_header("Content-Type", "text/plain; version=0.0.4")
  --- TODO: Add date header
  applet:start_response()
  applet:send(buffer:dump())

end)

