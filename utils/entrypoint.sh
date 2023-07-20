#!/bin/bash

. /etc/profile
if [ $# -eq 0 ]; then
  set -- /bin/bash
fi
exec "$@"
