#!/bin/bash

curl -k -u ''{{nsxuser}}':'{{nsxpasswd}}'' -X PATCH -H "Content-Type: application/json" -d '{"deployment_action":{"action":"DEPLOY"}}' https://{{nsxmanager}}/policy/api/v1/infra/sites/default/napp/deployment/platform
