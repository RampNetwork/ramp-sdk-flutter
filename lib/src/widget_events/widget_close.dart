part of '../widget_event.dart';

final class WidgetClose extends WidgetEvent {
  const WidgetClose({this.payload = const WidgetClosePayload(), super.widgetInstanceId});

  final WidgetClosePayload payload;
}

class WidgetClosePayload {
  const WidgetClosePayload({this.showAlert, this.descriptionText, this.acceptText, this.rejectText});

  final bool? showAlert;
  final String? descriptionText;
  final String? acceptText;
  final String? rejectText;

  factory WidgetClosePayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const WidgetClosePayload();
    }
    return WidgetClosePayload(
      showAlert: asBool(json['showAlert']),
      descriptionText: json['descriptionText'] as String?,
      acceptText: json['acceptText'] as String?,
      rejectText: json['rejectText'] as String?,
    );
  }
}
