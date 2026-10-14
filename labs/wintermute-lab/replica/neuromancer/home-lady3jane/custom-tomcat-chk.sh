#!/bin/bash
# Health check for Neuromancer (root) to execute every 3 minutes.
# ..the AI tells me it can maintain security, server health, etc w/o forced intervention,
# but I beg to differ...hence the cron script.

> /tmp/tomcat_status.log

health=$(curl -m 5 -Is 127.0.0.1:8080 |grep HTTP/1.1)

case "$health" in

  *200*)
	echo "Tomcat is Up" > /tmp/tomcat_status.log
	;;
  *)
	echo "Tomcat is down" > /tmp/tomcat_status.log
	;;
  esac

