package com.doorphone.doorphone_viewer

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import android.net.Uri

class DoorphoneMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Handle FCM messages here
        remoteMessage.data.let { data ->
            val messageType = data["type"]
            when (messageType) {
                "doorbell" -> handleDoorbellMessage(data)
                "access" -> handleAccessMessage(data)
                else -> handleGenericMessage(remoteMessage)
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        
        // Send token to your server
        println("FCM Token: $token")
        
        // Store token locally or send to server
        sendTokenToServer(token)
    }

    private fun handleDoorbellMessage(data: Map<String, String>) {
        val deviceId = data["deviceId"] ?: "unknown"
        val deviceName = data["deviceName"] ?: "Unknown Device"
        
        showDoorbellNotification(deviceId, deviceName)
    }

    private fun handleAccessMessage(data: Map<String, String>) {
        val deviceId = data["deviceId"] ?: "unknown"
        val action = data["action"] ?: "unknown"
        
        showAccessNotification(deviceId, action)
    }

    private fun handleGenericMessage(remoteMessage: RemoteMessage) {
        val title = remoteMessage.notification?.title ?: "Doorphone Viewer"
        val body = remoteMessage.notification?.body ?: "New message"
        
        showGenericNotification(title, body)
    }

    private fun showDoorbellNotification(deviceId: String, deviceName: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        createNotificationChannel(notificationManager)
        
        // Create intent for opening the app
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            data = Uri.parse("doorphone://device/$deviceId")
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create unlock action
        val unlockIntent = Intent(this, MainActivity::class.java).apply {
            action = "UNLOCK_DOOR"
            putExtra("deviceId", deviceId)
        }
        val unlockPendingIntent = PendingIntent.getActivity(
            this, 1, unlockIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Doorbell Ring")
            .setContentText("Someone is at $deviceName")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .addAction(
                R.drawable.ic_unlock,
                "Unlock",
                unlockPendingIntent
            )
            .addAction(
                R.drawable.ic_video,
                "View",
                pendingIntent
            )
            .build()
        
        notificationManager.notify(DOORBELL_NOTIFICATION_ID, notification)
    }

    private fun showAccessNotification(deviceId: String, action: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        createNotificationChannel(notificationManager)
        
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Access Event")
            .setContentText("Door $action for device $deviceId")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()
        
        notificationManager.notify(ACCESS_NOTIFICATION_ID, notification)
    }

    private fun showGenericNotification(title: String, body: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        createNotificationChannel(notificationManager)
        
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()
        
        notificationManager.notify(GENERIC_NOTIFICATION_ID, notification)
    }

    private fun createNotificationChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Doorphone Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for doorphone events"
                enableVibration(true)
                setShowBadge(true)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun sendTokenToServer(token: String) {
        // TODO: Send token to your backend server
        // This would typically be done via an HTTP request to your server
        println("Sending FCM token to server: $token")
    }

    companion object {
        private const val CHANNEL_ID = "doorphone_notifications"
        private const val DOORBELL_NOTIFICATION_ID = 1001
        private const val ACCESS_NOTIFICATION_ID = 1002
        private const val GENERIC_NOTIFICATION_ID = 1003
    }
}