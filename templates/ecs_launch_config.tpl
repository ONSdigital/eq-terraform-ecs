#!/bin/bash
echo ECS_CLUSTER=${ECS_CLUSTER} > /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"] >> /etc/ecs/ecs.config

echo respawn >> /etc/init/ecs.conf
echo respawn limit 10 5 >> /etc/init/ecs.conf