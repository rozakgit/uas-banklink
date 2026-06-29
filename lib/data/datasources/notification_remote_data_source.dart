import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.get('/v1/notifications');
    final List data = response['data'];
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<void> markAsRead(int id) async {
    await apiClient.put('/v1/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await apiClient.put('/v1/notifications/read-all');
  }
}
