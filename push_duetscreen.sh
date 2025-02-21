if [ -z "$REMOTE_HOST" ]; then
  echo "Error: REMOTE_HOST is not specified."
  exit 1
fi

command ssh root@$REMOTE_HOST 'start-stop-daemon -K -n DuetScreen'
command ssh root@$REMOTE_HOST 'pkill -9 DuetScreen'
scp output/target/usr/bin/DuetScreen root@$REMOTE_HOST:/usr/bin/DuetScreen
command ssh root@$REMOTE_HOST 'start-stop-daemon -S DuetScreen'