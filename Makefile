# Variables
MOODLE_DOCKER_WWWROOT=./moodle
MOODLE_DOCKER_DB=pgsql

# Targets
quick-start:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	git clone -b MOODLE_403_STABLE git://git.moodle.org/moodle.git $(MOODLE_DOCKER_WWWROOT); \
	cp config.docker-template.php $(MOODLE_DOCKER_WWWROOT)/config.php; \
	bin/moodle-docker-compose up -d; \
	bin/moodle-docker-wait-for-db;

run-multiple-instances:
	export COMPOSE_PROJECT_NAME=moodle34; \
	export MOODLE_DOCKER_WEB_PORT=1234; \
	make quick-start;

behat-tests:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver php admin/tool/behat/cli/init.php; \
	bin/moodle-docker-compose exec -u www-data webserver php admin/tool/behat/cli/run.php --tags=@auth_manual;

phpunit-tests:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver php admin/tool/phpunit/cli/init.php; \
	bin/moodle-docker-compose exec webserver vendor/bin/phpunit auth/manual/tests/manual_test.php;

manual-testing:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver php admin/cli/install_database.php --agree-license --fullname="Docker moodle" --shortname="docker_moodle" --summary="Docker moodle site" --adminpass="test" --adminemail="admin@example.com";

behat-tests-app:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	git clone https://github.com/moodlehq/moodle-local_moodleappbehat "$(MOODLE_DOCKER_WWWROOT)/local/moodleappbehat"; \
	make behat-tests;

xdebug-enable:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver pecl install xdebug; \
	read -r -d '' conf <<'EOF' ; \
	xdebug.mode = debug; \
	xdebug.client_host = host.docker.internal; \
EOF \
	bin/moodle-docker-compose exec webserver bash -c "echo '$$conf' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"; \
	bin/moodle-docker-compose exec webserver docker-php-ext-enable xdebug; \
	bin/moodle-docker-compose restart webserver;

xdebug-disable:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver sed -i 's/^zend_extension=/; zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
	bin/moodle-docker-compose restart webserver;

stop-containers:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose stop;

restart-containers:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose start;

ssh:
	export MOODLE_DOCKER_WWWROOT=$(MOODLE_DOCKER_WWWROOT); \
	export MOODLE_DOCKER_DB=$(MOODLE_DOCKER_DB); \
	bin/moodle-docker-compose exec webserver /bin/bash;