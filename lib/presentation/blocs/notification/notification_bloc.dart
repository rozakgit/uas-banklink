import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
  }

  Future<void> _onLoad(NotificationLoadRequested event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final data = await repository.getNotifications();
      emit(NotificationLoaded(data));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(NotificationMarkAsReadRequested event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.id);
      add(NotificationLoadRequested());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(NotificationMarkAllAsReadRequested event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAllAsRead();
      add(NotificationLoadRequested());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
