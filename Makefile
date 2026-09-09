.PHONY: get format analyze test ios
.DEFAULT_GOAL := test

get:
	flutter pub get

format:
	dart format lib test example/lib

analyze:
	dart analyze

test: get format analyze
	flutter test

build: get
	cd example && flutter build ios --debug --no-codesign
	cd example && flutter build apk --debug

ios:
	@id=$$(flutter devices --device-connection attached | grep SimRuntime.iOS \
	| head -n1 | cut -d'•' -f2 | xargs); \
	[ -n "$$id" ] || (echo "No iOS device found" && exit 1); \
	cd example && flutter run -d $$id
