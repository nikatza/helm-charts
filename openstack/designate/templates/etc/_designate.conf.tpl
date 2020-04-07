[DEFAULT]
# Where an option is commented out, but filled in this shows the default
# value of that option

########################
## General Configuration
########################
# Show more verbose log output (sets INFO log level output)
verbose = True

# Show debugging output in logs (sets DEBUG log level output)
debug = {{ .Values.debug }}

# pybasedir
#
pybasedir = /

# Top-level directory for maintaining designate's state
state_path = /var/lib/designate

log_config_append = /etc/designate/logging.conf

# path to api-paste configuration
api_paste_config = /etc/designate/api-paste.ini


# Use "sudo designate-rootwrap /etc/designate/rootwrap.conf" to use the real
# root filter facility.
# Change to "sudo" to skip the filtering and just run the command directly
#root_helper = sudo designate-rootwrap /etc/designate/rootwrap.conf

# Which networking API to use, Defaults to neutron
network_api = neutron

# Supported record types
#supported_record_type = A, AAAA, CNAME, MX, SRV, TXT, SPF, NS, PTR, SSHFP, SOA

# Setting SOA defaults
default_soa_refresh_min = 3500
default_soa_refresh_max = 3600
default_soa_retry = 600
default_soa_expire = 3600000
default_soa_minimum = 300

# Setting default quotas
# most default quotas are 0 to enforce usage of the Resource Management tool in Elektra
quota_zones = 0
quota_zone_recordsets = 0
quota_zone_records = 0
quota_recordset_records = 20
quota_api_export_size = 1000

rpc_response_timeout = {{ .Values.rpc_response_timeout | default .Values.global.rpc_response_timeout | default 300 }}
rpc_workers = {{ .Values.rpc_workers | default .Values.global.rpc_workers | default 1 }}

wsgi_default_pool_size = {{ .Values.wsgi_default_pool_size | default .Values.global.wsgi_default_pool_size | default 100 }}
min_pool_size = {{ .Values.min_pool_size | default .Values.global.min_pool_size | default 10 }}
max_pool_size = {{ .Values.max_pool_size | default .Values.global.max_pool_size | default 100 }}
max_overflow = {{ .Values.max_overflow | default .Values.global.max_overflow | default 50 }}

#transport_url = rabbit://{{ .Values.rabbitmq.users.default.user | default "rabbitmq" }}:{{ .Values.rabbitmq.users.default.password }}@{{.Release.Name}}-rabbitmq.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}:{{ .Values.rabbitmq.port | default 5672 }}/{{ .Values.rabbitmq.virtual_host | default "/" }}

[oslo_policy]
policy_file = policy.json

[oslo_messaging_notifications]
driver = noop

[oslo_messaging_rabbit]
rabbit_userid = {{ .Values.rabbitmq.users.default.user | default "rabbitmq" }}
rabbit_password = {{ .Values.rabbitmq.users.default.password }}
rabbit_host = {{.Release.Name}}-rabbitmq.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}
rabbit_port = {{ .Values.rabbitmq.port | default 5672 }}
rabbit_virtual_host = {{ .Values.rabbitmq.virtual_host | default "/" }}
rabbit_ha_queues = {{ .Values.rabbitmq.ha_queues | default "false" }}

########################
## Service Configuration
########################
#-----------------------
# Central Service
#-----------------------
[service:central]
# Number of central worker processes to spawn
workers = 2

# Number of central greenthreads to spawn
#threads = 1000

# Maximum domain name length
#max_domain_name_len = 255

# Maximum recordset name length
#max_recordset_name_len = 255

# Minimum TTL
#min_ttl = None

# The name of the default pool
default_pool_id = '794ccc2c-d751-44fe-b57f-8894c9f5c842'

## Managed resources settings

# Email to use for managed resources like domains created by the FloatingIP API
#managed_resource_email = hostmaster@example.com.

# Tenant ID to own all managed resources - like auto-created records etc.
#managed_resource_tenant_id = 123456

# What filters to use. They are applied in order listed in the option, from
# left to right
scheduler_filters = {{ .Values.scheduler_filters }}

#-----------------------
# API Service
#-----------------------
[service:api]
# Number of api worker processes to spawn
#workers = None

# Number of api greenthreads to spawn
#threads = 1000

# Enable host request headers
#enable_host_header = False

# Make Zone description field mandatory
#description_field_mandatory = False

# The base uri used in responses
api_base_uri = https://{{ include "designate_api_endpoint_host_public" .}}:{{.Values.global.designate_api_port_public}}

# Address to bind the API server
api_host = 0.0.0.0

# Port the bind the API server to
api_port = {{.Values.global.designate_api_port_internal}}

# Maximum line size of message headers to be accepted. max_header_line may
# need to be increased when using large tokens (typically those generated by
# the Keystone v3 API with big service catalogs).
#max_header_line = 16384

# Authentication strategy to use - can be either "noauth" or "keystone"
auth_strategy = keystone

# Enable Version 1 API (deprecated)
enable_api_v1 = False

# Enabled API Version 1 extensions
# Can be one or more of : diagnostics, quotas, reports, sync, touch
enabled_extensions_v1 = diagnostics, quotas, reports, sync, touch

# Enable Version 2 API
enable_api_v2 = True

# Enabled API Version 2 extensions
enabled_extensions_v2 = quotas, reports

# Default per-page limit for the V2 API, a value of None means show all results
# by default
#default_limit_v2 = 20

# Max page size in the V2 API
#max_limit_v2 = 1000

# Enable Admin API (experimental)
#enable_api_admin = True

# Enabled Admin API extensions
# Can be one or more of : reports, quotas, counts, tenants, target_sync
# zone export is in zones extension
#enabled_extensions_admin = quotas

# Default per-page limit for the Admin API, a value of None means show all results
# by default
#default_limit_admin = 20

# Max page size in the Admin API
#max_limit_admin = 1000

# Show the pecan HTML based debug interface (v2 only)
# This is only useful for development, and WILL break python-designateclient
# if an error occurs
#pecan_debug = False

#-----------------------
# Keystone Middleware
#-----------------------
[keystone_authtoken]
auth_plugin = v3password
auth_version = v3
auth_interface = internal
www_authenticate_uri = https://{{include "keystone_api_endpoint_host_public" .}}/v3
auth_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
username = {{ .Values.global.designate_service_user }}
password = {{ .Values.global.designate_service_password }}
user_domain_name = {{.Values.global.keystone_service_domain | default "Default"}}
project_name = {{.Values.global.keystone_service_project |  default "service"}}
project_domain_name = {{.Values.global.keystone_service_domain | default "Default"}}
region_name = {{.Values.global.region}}
memcached_servers = {{.Release.Name}}-memcached.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}:{{.Values.global.memcached_port_public | default 11211}}
insecure = True
token_cache_time = 600
include_service_catalog = true
service_type = dns

#-----------------------

# CORS Middleware
#-----------------------
[cors]

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. (list value)
#allowed_origin = <None>

# Indicate that the actual request can include user credentials (boolean value)
#allow_credentials = true

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
#expose_headers = X-OpenStack-Request-ID,Host

# Maximum cache age of CORS preflight requests. (integer value)
#max_age = 3600

# Indicate which methods can be used during the actual request. (list value)
#allow_methods = GET,PUT,POST,DELETE,PATCH,HEAD

# Indicate which header field names may be used during the actual request.
# (list value)
#allow_headers = X-Auth-Token,X-Auth-Sudo-Tenant-ID,X-Auth-Sudo-Project-ID,X-Auth-All-Projects,X-Designate-Edit-Managed-Records

[cors.subdomain]

# Indicate whether this resource may be shared with the domain received in the
# requests "origin" header. (list value)
#allowed_origin = <None>

# Indicate that the actual request can include user credentials (boolean value)
#allow_credentials = true

# Indicate which headers are safe to expose to the API. Defaults to HTTP Simple
# Headers. (list value)
#expose_headers = X-OpenStack-Request-ID,Host

# Maximum cache age of CORS preflight requests. (integer value)
#max_age = 3600

# Indicate which methods can be used during the actual request. (list value)
#allow_methods = GET,PUT,POST,DELETE,PATCH,HEAD

# Indicate which header field names may be used during the actual request.
# (list value)
#allow_headers = X-Auth-Token,X-Auth-Sudo-Tenant-ID,X-Auth-Sudo-Project-ID,X-Auth-All-Projects,X-Designate-Edit-Managed-Records

#-----------------------
# mDNS Service
#-----------------------
[service:mdns]
# Number of mdns worker processes to spawn
workers = 1

# Number of mdns greenthreads to spawn
threads = 1000

# mDNS Bind Host
host = 0.0.0.0

# mDNS Port Number
port = 5354

# mDNS TCP Backlog
#tcp_backlog = 100

# mDNS TCP Receive Timeout
#tcp_recv_timeout = 0.5

# Enforce all incoming queries (including AXFR) are TSIG signed
query_enforce_tsig = {{ .Values.query_enforce_tsig }}

# Send all traffic over TCP
#all_tcp = False

# Maximum message size to emit
#max_message_size = 65535

#-----------------------
# Agent Service
#-----------------------
[service:agent]
#workers = None
#host = 0.0.0.0
#port = 5358
#tcp_backlog = 100
#allow_notify = 127.0.0.1
#masters = 127.0.0.1:5354
#backend_driver = fake
#transfer_source = None
#notify_delay = 0

#------------------------
# Deleted domains purging
#------------------------
[zone_manager_task:domain_purge]
# How frequently to purge deleted domains, in seconds
#interval = 3600  # 1h

# How many records to be deleted on each run
#batch_size = 100

# How old deleted records should be (deleted_at) to be purged, in seconds
#time_threshold = 604800  # 7 days

#------------------------
# Delayed zones NOTIFY
#------------------------
[zone_manager_task:delayed_notify]
# How frequently to scan for zones pending NOTIFY, in seconds
#interval = 5

# How many zones to receive NOTIFY on each run
#batch_size = 100

#-----------------------
# Worker Service
#-----------------------
[service:worker]
# Whether to send events to worker instead of Pool Manager
enabled = {{.Values.worker_enabled}}

# Number of Worker processes to spawn
workers = 1

# Number of Worker greenthreads to spawn
threads = 1000

# The percentage of servers requiring a successful update for a zone change
# to be considered active
threshold_percentage =  {{ .Values.worker_threshold_percentage }}

# The time to wait for a response from a server
#poll_timeout = 30

# The time between retrying to send a request and waiting for a response from a
# server
poll_retry_interval = {{.Values.worker_poll_retry_interval}}

# The maximum number of times to retry sending a request and wait for a
# response from a server
poll_max_retries = {{.Values.worker_poll_max_retries}}

# The time to wait before sending the first request to a server
#poll_delay = 5

# Whether to allow worker to send NOTIFYs. NOTIFY requests to mdns will noop
notify = {{ .Values.worker_notify }}

##############
## Network API
##############
[network_api:neutron]
# Comma separated list of values, formatted "<name>|<neutron_uri>"
endpoints = {{ .Values.global.region }}|https://network-3.{{ .Values.global.region }}.{{ .Values.global.tld }}
endpoint_type = publicURL
timeout = 20
insecure = True
#admin_username = designate
#admin_password = designate
#admin_tenant_name = designate
#auth_url = http://localhost:35357/v2.0
#auth_strategy = keystone
#ca_certificates_file =

########################
## Storage Configuration
########################
#-----------------------
# SQLAlchemy Storage
#-----------------------
[storage:sqlalchemy]
# Database connection string - to configure options for a given implementation
# like sqlalchemy or other see below
#connection = sqlite:///$state_path/designate.sqlite
connection = {{ include "db_url_mysql" . }}

mysql_sql_mode = TRADITIONAL

#connection_debug = 0
#connection_trace = False
#sqlite_synchronous = True
#idle_timeout = 3600
#max_retries = 10
retry_interval = 1

########################
## Handler Configuration
########################
#-----------------------
# Nova Fixed Handler
#-----------------------
[handler:nova_fixed]
# Domain ID of domain to create records in. Should be pre-created
#domain_id = c7deacad-7ce7-4c9f-bf6a-6203f702750d
#notification_topics = notifications_designate
#control_exchange = 'nova'
#format = '%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(domain)s'
#format = '%(hostname)s.%(project)s.%(domain)s'
#format = '%(hostname)s.%(domain)s'

#------------------------
# Neutron Floating Handler
#------------------------
[handler:neutron_floatingip]
# Domain ID of domain to create records in. Should be pre-created
#domain_id = c7deacad-7ce7-4c9f-bf6a-6203f702750d
#notification_topics = notifications_designate
#control_exchange = 'neutron'
#format = '%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(domain)s'
#format = '%(hostname)s.%(project)s.%(domain)s'
#format = '%(hostname)s.%(domain)s'

#############################
## Agent Backend Configuration
#############################
[backend:agent:bind9]
#rndc_host = 10.44.11.98
#rndc_port = 953
#rndc_config_file = /etc/rndc.conf
#rndc_key_file = /etc/rndc.key
#zone_file_path = $state_path/zones
#query_destination = 127.0.0.1
#
[backend:agent:denominator]
#name = dynect
#config_file = /etc/denominator.conf

########################
## Library Configuration
########################
[oslo_concurrency]
# Path for Oslo Concurrency to store lock files, defaults to the value
# of the state_path setting.
#lock_path = $state_path

########################
## Coordination
########################
[coordination]
# URL for the coordination backend to use.
#backend_url = kazoo://127.0.0.1/

########################
## Hook Points
########################
# Hook Points are enabled when added to the config and there has been
# a package that provides the corresponding named designate.hook_point
# entry point.

# [hook_point:name_of_hook_point]
# some_param_for_hook = 42
# Hooks can be disabled in the config
# enabled = False

# Hook can also be applied to the import path when the hook has not
# been given an explicit name. The name is created from the hook
# target function / method:
#
#   name = '%s.%s' % (func.__module__, func.__name__)

# [hook_point:designate.api.v2.controllers.zones.get_one]

# Defines CADF Audit Middleware section
# this is for the cadf audit messaging
[audit_middleware_notifications]
topics = notifications
driver = messagingv2
transport_url = rabbit://rabbitmq:{{ .Values.rabbitmq_notifications.users.default.password }}@designate-rabbitmq-notifications:5672/
mem_queue_size = 1000
