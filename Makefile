SHELL ?= /bin/bash

# Support an optional .env file to defined env variables like FLASK_ENV
# NOTE that the Jenkinsfile will define these for you - this is strictly for
# convenience on your development laptop
include $(shell ls .env 2> /dev/null)
export

PYTHON ?= python
PYPI_PROXY ?= https://nexus.prod.cloud.fedex.com:8443/nexus/repository/pypi-proxy/simple
VENV ?= ./env
BUILD_DIR ?= ./build
BUILD_DIR_EXISTS = $(BUILD_DIR)/.touched
DEV_ENV_INSTALL = $(BUILD_DIR)/.dev-env-installed
JUNIT_XML ?= $(BUILD_DIR)/test-results.xml
COVER_XML ?= $(BUILD_DIR)/test-coverage.xml
PYLINT_REPORT ?= $(BUILD_DIR)/pylint-report.log
TEST_DIR ?= $(BUILD_DIR)/src/
TEST_OPTS ?= -v --junitxml "$(JUNIT_XML)" --ignore=tests/test_model.py --cov=src --cov-report "xml:$(COVER_XML)"
TEST_MODEL ?= tests/test_model.py --junitxml
WORKSPACE ?= .
VENDOR_DIR ?= ./vendor


.PHONY: venv
venv: $(VENV)/bin/activate

$(VENV)/bin/activate: requirements.txt
	chmod +x ci/*.sh
	# test -d $(VENV) || $(PYTHON) -m pip list
	# test -d $(VENV) || $(PYTHON) -m pip install -i $(PYPI_PROXY) --upgrade virtualenv
	test -d $(VENV) || PYPI_PROXY="$(PYPI_PROXY)" WORKSPACE="$(WORKSPACE)"
	./ci/virtualenv-wrapper.sh $(VENV)
	. $(VENV)/bin/activate; python -m pip install -i $(PYPI_PROXY) --upgrade pip
	. $(VENV)/bin/activate; python -m pip install -i $(PYPI_PROXY) -r requirements.txt --no-deps;
#	touch $(VENV)/bin/activate

.PHONY: dev-env
dev-env: $(DEV_ENV_INSTALL)

$(DEV_ENV_INSTALL) : requirements_jenkins.txt $(VENV)/bin/activate $(BUILD_DIR_EXISTS)
	. $(VENV)/bin/activate; $(PYTHON) -m pip install -i $(PYPI_PROXY) -r requirements_jenkins.txt ;touch $(DEV_ENV_INSTALL)

$(BUILD_DIR_EXISTS):
	mkdir -p $(BUILD_DIR)
	touch $(BUILD_DIR_EXISTS)

.PHONY: test
test: dev-env $(BUILD_DIR_EXISTS)
	. $(VENV)/bin/activate;$(PYTHON) -m pytest $(TEST_OPTS);
	sed -i 's#<?xml version=\"1.0\" encoding=\"utf-8\"?><testsuites>##g' $(JUNIT_XML)
	sed -i 's#</testsuites>##g' $(JUNIT_XML)

.PHONY: test_model
test_model: dev-env $(BUILD_DIR_EXISTS)
	. $(VENV)/bin/activate;export hscode_test_country_code=$(COUNTRY_CD);$(PYTHON) -m pytest $(TEST_MODEL) $(BUILD_DIR)/test-results-$(COUNTRY_CD).xml;

.PHONY: analyze
analyze: dev-env $(BUILD_DIR_EXISTS)
	. $(VENV)/bin/activate; python -m pylint src --exit-zero --output-format=parseable --reports=no | tee $(PYLINT_REPORT)


# Only really useful for PCF deploys
.PHONY: vendor
vendor: $(VENV)/bin/activate
	mkdir -p "$(VENDOR_DIR)"
	. $(VENV)/bin/activate; python -m pip freeze > "$(VENDOR_DIR)/requirements.txt"
	cat "$(VENDOR_DIR)/requirements.txt"
	. $(VENV)/bin/activate; pushd "$(VENDOR_DIR)"; python -m pip download -i "${PYPI_PROXY}" -r requirements.txt --no-deps; popd

.PHONY: clean
clean:
	rm -f "$(DEV_ENV_INSTALL)" "$(BUILD_DIR_EXISTS)" "$(JUNIT_XML)" "$(PYLINT_REPORT)" "$(COVER_XML)"
	rm -fr "$(VENV)" "$(BUILD_DIR)" "$(VENDOR_DIR)"
	rm -fr "./.downloads"
	rm -fr "./tfhub"
	rm -fr "./security"

.PHONY: freeze
freeze:
	. $(VENV)/bin/activate; python -m pip freeze

.PHONY: package
package: dev-env $(BUILD_DIR_EXISTS)
	. $(VENV)/bin/activate; python setup.py sdist bdist_wheel

.PHONY: deploy
deploy: package
	. $(VENV)/bin/activate; python -m twine upload --repository-url "$(PYPI_HOST)" dist/*

.PHONY: sys-python-var-check
sys-python-var-check:
	./ci/test-python.sh
