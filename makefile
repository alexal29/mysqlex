SHELL := /bin/bash
MYSQL_PASS=root
MYSQL_DATABASE=test
MYSQL_CONTAINER=mysql_mem
EXPORTER_CONTAINER=mysql-exporter_mem
.PHONY: init create-exporter-user seed

default: init

create-exporter-user:
	$(eval EXPORTER_IP := $(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(EXPORTER_CONTAINER)))
	@docker exec -t $(MYSQL_CONTAINER) sh -c "sed 's/localhost/$(EXPORTER_IP)/g' data/exporter.sql > create-exporter.sql; export MYSQL_PWD=$(MYSQL_PASS); mysql $(MYSQL_DATABASE) < create-exporter.sql"

seed:
	@docker exec -t $(MYSQL_CONTAINER) sh -c "export MYSQL_PWD=$(MYSQL_PASS); mysql $(MYSQL_DATABASE) < data/seed.sql"

init:
	docker compose down -v
	docker compose up -d
	@echo "Waiting for database connection..."
	@while ! docker exec -t $(MYSQL_CONTAINER) sh -c "mysql -p$(MYSQL_PASS) -e 'select 1' $(MYSQL_DATABASE) &>/dev/null"; do \
    sleep 1; \
	done
	@make -s create-exporter-user
	@make -s seed