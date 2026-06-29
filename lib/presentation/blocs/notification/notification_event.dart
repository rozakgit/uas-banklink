part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {}

class NotificationMarkAsReadRequested extends NotificationEvent {
  final int id;
  const NotificationMarkAsReadRequested(this.id);
  @override
  List<Object> get props => [id];
}

class NotificationMarkAllAsReadRequested extends NotificationEvent {}
