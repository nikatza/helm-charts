#!/bin/bash
set -xeuo pipefail

nova-manage api_db sync
nova-manage db sync
nova-manage db null_instance_uuid_scan --delete

# online data migration run by online-migration-job

{{ include "utils.proxysql.proxysql_signal_stop_script" . }}
