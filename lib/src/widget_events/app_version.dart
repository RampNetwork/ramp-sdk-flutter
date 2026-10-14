part of '../widget_event.dart';

final class AppVersion extends WidgetEvent {
  const AppVersion(this.payload, {super.widgetInstanceId});

  final AppVersionPayload payload;
}

class AppVersionPayload {
  const AppVersionPayload({this.version});

  final String? version;

  factory AppVersionPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AppVersionPayload();
    }
    return AppVersionPayload(version: asString(json['version']));
  }
}
