#!/bin/sh
cd "$(dirname "$0")"
PORT="${1:-9000}"
only_pids() { grep -E '^[0-9]+$' | grep -vxE '0|1'; }
PIDS=$(lsof -ti "tcp:$PORT" -sTCP:LISTEN 2>/dev/null | only_pids)
[ -z "$PIDS" ] && PIDS=$(fuser "$PORT/tcp" 2>/dev/null | tr -s ' ' '\n' | only_pids)
[ -z "$PIDS" ] && PIDS=$(ps ax -o pid=,command= 2>/dev/null | grep "[G]ameServer $PORT" | awk '{print $1}' | only_pids)
[ -z "$PIDS" ] && PIDS=$(ps -o pid,args 2>/dev/null | grep "[G]ameServer $PORT" | awk '{print $1}' | only_pids)
if [ -z "$PIDS" ]; then
  echo "Nothing to stop -- no server is using port $PORT."
  exit 0
fi
for P in $PIDS; do
  echo "Stopping PID $P on port $PORT"
  kill "$P" 2>/dev/null
done
sleep 1
for P in $PIDS; do
  kill -0 "$P" 2>/dev/null && kill -9 "$P" 2>/dev/null
done
echo "Server on port $PORT stopped."
