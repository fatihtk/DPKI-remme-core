# Copyright 2018 REMME
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------

PROTO_SRC_DIR = ./protos
PROTO_DST_DIR = ./remme/protos

TOTAL_SUPPLY ?= 10000000000000

run:
	docker-compose up

run_dev:
	docker-compose -f docker-compose.dev.yml up

shell:
	docker exec -it $(shell docker-compose ps -q shell) bash

test:
	docker-compose -f docker-compose.test.yml up --abort-on-container-exit

genesis:
	docker-compose -f docker-compose.genesis.yml run -e REM_TOKEN_SUPPLY=$(TOTAL_SUPPLY) genesis

reload_module:
	pip3 install --upgrade /remme

build_protobuf:
	protoc -I=$(PROTO_SRC_DIR) --python_out=$(PROTO_DST_DIR) $(PROTO_SRC_DIR)/*.proto

build_docker:
	docker build --target development --tag remme/remme-core-dev:latest .
	docker build --target production --tag remme/remme-core:latest .

rebuild_docker:
	docker build --target development --tag remme/remme-core-dev:latest --no-cache .
	docker build --target production --tag remme/remme-core:latest --no-cache .
