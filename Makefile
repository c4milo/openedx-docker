.PHONY: all configure build migrate assets up daemon lms-assets cms-assets

all: configure build migrate assets daemon

##################### Bootstrapping commands

configure:
	./configure

build:
	docker-compose build

migrate:
	docker-compose run --rm lms bash -c "./wait-for-mysql.sh && ./manage.py lms --settings=production migrate"
	docker-compose run --rm cms bash -c "./wait-for-mysql.sh && ./manage.py cms --settings=production migrate"

assets: lms-assets cms-assets

lms-assets:
	docker-compose run --rm lms paver update_assets lms --settings=production --collect-log=/openedx/data/logs

cms-assets:
	docker-compose run --rm cms paver update_assets cms --settings=production --collect-log=/openedx/data/logs

##################### Running commands

up:
	docker-compose up

daemon:
	docker-compose up -d && \
	echo "Daemon is up and running"

stop:
	docker-compose stop

##################### Additional commands

lms-shell:
	docker-compose run --rm lms ./manage.py lms --settings=production shell
cms-shell:
	docker-compose run --rm lms ./manage.py cms --settings=production shell

import-demo-course:
	docker-compose run --rm cms /bin/bash -c "git clone https://github.com/edx/edx-demo-course ../edx-demo-course && git -C ../edx-demo-course checkout open-release/ginkgo.master && python ./manage.py cms --settings=production import ../data ../edx-demo-course"

create-staff-user:
	docker-compose run --rm lms /bin/bash -c "./manage.py lms --settings=production manage_user --superuser --staff ${USERNAME} ${EMAIL} && ./manage.py lms --settings=production changepassword ${USERNAME}"
