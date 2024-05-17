# Variables
MOODLE_DOCKER_WWWROOT=./moodle
MOODLE_DOCKER_DB=mysql

# Targets
install:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	git clone -b MOODLE_403_STABLE git://git.moodle.org/moodle.git ./moodle; \
	cp config.docker-template.php ./moodle/config.php; \
	git clone -b main git@github.com:EurecatAcademyLab/local_forum_moderation_premium.git ./moodle/local/forummoderation; \
	git clone -b main git@github.com:EurecatAcademyLab/local_survey_intelligence_premium.git ./moodle/local/survey_intelligence; \
	bin/moodle-docker-compose up -d; \
	bin/moodle-docker-wait-for-db; \
	bin/moodle-docker-compose exec webserver php admin/cli/install_database.php --agree-license --adminpass=12345 --adminemail=jmdesarrollo82@gmail.com --fullname="Moodle site" --shortname="moodlesite" --summary="A moodle site for testing" --supportemail="jmdesarrollo82@gmail.com"; \
	bin/moodle-docker-compose exec webserver php admin/tool/phpunit/cli/init.php; \
	bin/moodle-docker-compose exec webserver php admin/tool/behat/cli/init.php;

run-multiple-instances:
	export COMPOSE_PROJECT_NAME=moodle34; \
	export MOODLE_DOCKER_WEB_PORT=1234; \
	make quick-start;

behat-tests:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec -u www-data webserver php admin/tool/behat/cli/run.php --tags=@auth_manual;

phpunit-tests:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec webserver vendor/bin/phpunit auth/manual/tests/manual_test.php;

manual-testing:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec webserver php admin/cli/install_database.php --agree-license --fullname="Docker moodle" --shortname="docker_moodle" --summary="Docker moodle site" --adminpass="test" --adminemail="admin@example.com";

behat-tests-app:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	git clone https://github.com/moodlehq/moodle-local_moodleappbehat "./moodle/local/moodleappbehat"; \
	make behat-tests;

xdebug-enable:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec webserver pecl install xdebug; \
    read -r -d '' conf <<'EOF' \
    xdebug.mode = debug \
    xdebug.client_host = host.docker.internal \
    xdebug.idekey=PHPSTORM \
EOF \
    moodle-docker-compose exec webserver bash -c "echo '$conf' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" \
	bin/moodle-docker-compose exec webserver docker-php-ext-enable xdebug; \
	bin/moodle-docker-compose restart webserver;

xdebug-disable:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec webserver sed -i 's/^zend_extension=/; zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
	bin/moodle-docker-compose restart webserver;

stop-containers:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose stop;

restart-containers:
	export MOODLE_DOCKER_SELENIUM_VNC_PORT=5900
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose start;

ssh:
	export MOODLE_DOCKER_WWWROOT=./moodle; \
	export MOODLE_DOCKER_DB=mysql; \
	bin/moodle-docker-compose exec webserver /bin/bash;