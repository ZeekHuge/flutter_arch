# Copyright ZeekHuge <contact@zeekhuge.me>
#
# License : Same as root repository

FILES_TO_WATCH_UNIT_TEST ?= lib/ test/
CODE_COVERAGE_HTML_OUTPUT ?= coverage/html/

.PHONY:all
all: DEPENDENCY_CHECK

.PHONY:DEPENDENCY_CHECK
DEPENDENCY_CHECK:
	@which which >/dev/null || echo ' - Could not find whereis tool'
	@which flutter >/dev/null || echo ' - Could not find flutter'
	@which entr >/dev/null || echo ' - Could not find entr tool'
	@which genhtml >/dev/null || echo ' - Could not find gethtml'

.PHONY:continuous-unit-test
continuous-unit-test: DEPENDENCY_CHECK
	@(find ${FILES_TO_WATCH_UNIT_TEST} | entr /bin/bash -c 'date && flutter test && echo -e "-----------\n-----------"')

.PHONY:get-codecoverage
get-codecoverage:
	@flutter test --coverage && genhtml -o ${CODE_COVERAGE_HTML_OUTPUT} coverage/lcov.info
	@echo ' - Html coverage reports at : ${CODE_COVERAGE_HTML_OUTPUT}'


