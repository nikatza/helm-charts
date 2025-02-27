- name: mysql.alerts
  rules:
  - alert: {{ include "alerts.service" . | title }}MariaDBTooManyConnections
    expr: (mysql_global_variables_max_connections{app=~"{{ include "fullName" . }}"} - mysql_global_status_threads_connected{app=~"{{ include "fullName" . }}"} < 200)
    for: 10m
    labels:
      context: datbase
      service: {{ include "alerts.service" . }}
      severity: info
      tier: {{ required ".Values.alerts.tier missing" .Values.alerts.tier }}
      support_group: {{ required ".Values.alerts.support_group missing" .Values.alerts.support_group }}
    annotations:
      description: {{ include "fullName" . }} has too many connections open. Please check the service containers.
      summary: {{ include "fullName" . }} has too many connections open.

  - alert: {{ include "alerts.service" . | title }}MariaDBSlowQueries
    expr: (rate(mysql_global_status_slow_queries{app=~"{{ include "fullName" . }}"}[30m]) > 0)
    for: 10m
    labels:
      context: database
      service: {{ include "alerts.service" . }}
      severity: info
      tier: {{ required ".Values.alerts.tier missing" .Values.alerts.tier }}
      support_group: {{ required ".Values.alerts.support_group missing" .Values.alerts.support_group }}
      playbook: 'docs/support/playbook/database/MariaDBSlowQueries'
    annotations:
      description: {{ include "fullName" . }} has reported slow queries. Please check the DB.
      summary: {{ include "fullName" . }} reports slow queries.

  - alert: {{ include "alerts.service" . | title }}MariaDBWaitingForLock
    expr: (mysql_info_schema_threads_seconds{app=~"{{ include "fullName" . }}", state=~"waiting for lock"} / 1000  > 15)
    for: 10m
    labels:
      context: database
      service: {{ include "alerts.service" . }}
      severity: warning
      tier: {{ required ".Values.alerts.tier missing" .Values.alerts.tier }}
      support_group: {{ required ".Values.alerts.support_group missing" .Values.alerts.support_group }}
    annotations:
      description: {{ include "fullName" . }} has queries waiting for lock more than 15 sec. Deadlock possible.
      summary: {{ include "fullName" . }} has queries waiting for lock.

  - alert: {{ include "alerts.service" . | title }}MariaDBHighRunningThreads
    expr: (mysql_global_status_threads_running{app=~"{{ include "fullName" . }}"} > 20)
    for: 10m
    labels:
      context: database
      service: {{ include "alerts.service" . }}
      severity: info
      tier: {{ required ".Values.alerts.tier missing" .Values.alerts.tier }}
      support_group: {{ required ".Values.alerts.support_group missing" .Values.alerts.support_group }}
      playbook: 'docs/support/playbook/manila/mariadb_high_running_threads'
    annotations:
      description: {{ include "fullName" . }} has more than 20 running threads.
      summary: {{ include "fullName" . }} running threads high.
