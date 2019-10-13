DARTANALYZER_FLAGS=--fatal-warnings

build: lib/*dart test/*dart deps
	dartanalyzer ${DARTANALYZER_FLAGS} lib/
	dartfmt -n --set-exit-if-changed lib/ test/
	flutter test --coverage

deps: pubspec.yaml
	pub get -v
	flutter pub get -v

reformatting:
	dartfmt -w lib/ test/

build-local: reformatting build
	genhtml -o coverage coverage/lcov.info
	open coverage/index.html

pana:
	pana --source path .

docs:
	rm -rf doc
	dartdoc

publish:
	pub publish