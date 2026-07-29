.PHONY: get analyze format test ios android

get:
	flutter pub get

analyze:
	dart analyze

format:
	dart format --line-length 120 lib test example/lib

test:
	flutter test

ios:
	cd example && flutter build ios --debug --no-codesign

android:
	cd example && flutter build apk --debug
