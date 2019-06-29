#
# Various utilities
#

PHONY: log_container_%
# show the log for a specific container common implementation
log_container_%:
	for pod in $$(kubectl get pods --namespace kpi | grep ^$* | awk '{ print $$1 }') ; do \
                kubectl logs $$pod --namespace kpi | sed "s/^/$$pod\ /"; \
        done

.PHONY: log_aggregator
# show the data aggregator log
log_aggregator: kubectl_use_context log_container_aggregator

.PHONY: log_importer
# show the database importer log
log_importer: kubectl_use_context log_container_mysql-importer

.PHONY: log_dbdump
# show the database dump log
log_dbdump: kubectl_use_context log_container_dbdump

.PHONY: log_dbsetup
# show the dbsetup log
log_dbsetup: kubectl_use_context log_container_dbsetup

.PHONY: log_grafana
# show the grafana log
log_grafana: kubectl_use_context log_container_grafana

.PHONY: tools_psql_shell
.ONESHELL:
# open a postgres shell
tools_psql_shell: kubectl_use_context
	pod=$$(kubectl get pods --namespace=kpi | grep postgres | awk '{ print $$1 }')
	kubectl exec -it $$pod --namespace=kpi -- su - postgres -c 'psql -d kpi'

