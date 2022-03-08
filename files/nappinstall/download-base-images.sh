#!/bin/bash

#Project Antrea
#docker pull projects.registry.vmware.com/antrea/antrea-ubuntu:v1.5.0

#Metallb
#docker pull quay.io/metallb/controller:main
#docker pull quay.io/metallb/speaker:main

#CertManager Files
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-controller:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-cainjector:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-webhook:19067763

#Project Contour
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/contour:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/envoy:19067763

docker pull projects.registry.vmware.com/nsx_application_platform/clustering/authserver:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/logrotate:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/cluster_api:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/common_agent:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/wait-for:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/druid:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluentd:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/kafka:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics-app:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_db_helper:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_manager:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_nsx_config:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/clients:19067761
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/pgpool:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/postgresql-repmgr:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_query_server:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/metrics-server:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/minio:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/mc:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/monitor:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluent-bit:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/redis:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/routing_controller:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/spark-operator:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/telemetry:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/trust-manager:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/zookeeper:19067763

