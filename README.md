# Phantombot-Docker
This is a Docker container for PhantomBot

To Run
```
docker run -d -e BOT_TWITCH_USERNAME= -e BOT_OAUTH= -e PANEL_USER= -e PANEL_PASSWORD= -e BOT_CHANNEL= \
  -e BOT_OWNER= -e GAMEWISPAUTH= -e GAMEWISPREFRESH= -e TIME_ZONE= \
  --name=phantombot m3adow/phantombot-docker:latest \
  -p 25000:25000 -p 25001:25001 -p 25002:25002 -p 25005:25005
```

MySQL Setup (untested)
```
-e MYSQL_HOST= -e MYSQL_PORT= -e MYSQL_NAME= -e MYSQL_USER= -e MYSQL_PASS=
```


This is still WIP
