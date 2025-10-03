#!/bin/bash

# Запускаем Redis
redis-server /etc/redis/redis.conf &

# Запускаем PostgreSQL
pg_ctlcluster 15 main start &

# Запускаем бота
ruby bin/bot