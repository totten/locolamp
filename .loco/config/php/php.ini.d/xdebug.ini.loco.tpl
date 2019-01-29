;; Configure XDebug
;; Note: After changing, you should reinitialize+restart PHP.

xdebug.remote_autostart=on
xdebug.remote_enable=on
xdebug.remote_mode=req
xdebug.remote_handler=dbgp
xdebug.remote_host=localhost
xdebug.remote_port={{XDEBUG_PORT}}
