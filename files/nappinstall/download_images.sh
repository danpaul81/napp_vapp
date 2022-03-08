#!/bin/bash

#Project Antrea
docker pull projects.registry.vmware.com/antrea/antrea-ubuntu:v1.5.0

#Metallb
docker pull quay.io/metallb/controller:main
docker pull quay.io/metallb/speaker:main

#CertManager Files
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-controller:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-cainjector:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/cert-manager-webhook:19067763

#Project Contour
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/contour:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/envoy:19067763

#NSXI Platform
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/authserver:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-check-nsx-licensing-status-with-lastline-cloud:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-ssl-tunnel:123-31bb14c6.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-proxy-nginx:123-d24e4997.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-webproxy-tunnel:123-256f91ff.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-register-nsx-to-lastline-cloud:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-update-nsx-licensing-status-for-lastline-cloud:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/cluster_api:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/logrotate:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/wait-for:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/common_agent:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/clients:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/core_collector:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/context_correlator:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/recommendation-spark-job:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/python-common:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/data-archiver:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/data-collection:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/druid:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluentd:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/intelligence-ui:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/kafka:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/latestflow:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/llanta-service:719-38dc10b0.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/llanta-nsxi-job:719-6b7b7175.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/llqueue-kafka-worker:719-9a708762.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/feature_switch_watcher:19067759
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/feature_switch_watcher:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/antimalware-ui:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics-app:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_db_helper:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_manager:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_nsx_config:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/pgpool:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/postgresql-repmgr:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/metrics_query_server:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/metrics-server:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/minio:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/mc:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/monitor:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-registration-scripts:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx_config:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-enable-disable-ids-events:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/feature_switch_watcher:19067761
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/clients:19067761
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-upload-nsx-config-to-lastline-cloud:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nsx-cloud-connector-worker:123-c33a1aa7.bionic
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/fluent-bit:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/hombre:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/nta_server:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/pubsub:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/raw_flow_correlator:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/recommendation:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/redis:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/reputation-service:19067759
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/routing_controller:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-asds:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-events-processor:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-scheduler-services:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/sa-web-services:19067767
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/over_flow_correlator:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/spark-job-manager:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/spark-operator:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/telemetry:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/trust-manager:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/visualization:19067763
docker pull projects.registry.vmware.com/nsx_application_platform/clustering/third-party/zookeeper:19067763
