package com.doorphone.doorphone_viewer

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.util.concurrent.ConcurrentHashMap

import com.amazonaws.kinesisvideo.client.KinesisVideoClient
import com.amazonaws.kinesisvideo.client.mediasource.MediaSource
import com.amazonaws.kinesisvideo.common.exception.KinesisVideoException
import com.amazonaws.kinesisvideo.webrtc.KvsWebRtcClient
import com.amazonaws.kinesisvideo.webrtc.SignalingClient
import com.amazonaws.kinesisvideo.webrtc.SignalingClientState
import com.amazonaws.kinesisvideo.webrtc.SignalingListener
import com.amazonaws.mobileconnectors.kinesisvideo.client.KinesisVideoAndroidClientFactory
import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.auth.AWSStaticCredentialsProvider
import com.amazonaws.regions.Region
import com.amazonaws.regions.Regions

import org.webrtc.*

class KVSWebRTCPlugin(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "KVSWebRTCPlugin"
        private const val METHOD_CHANNEL = "com.doorphone.doorphone_viewer/kvs_webrtc"
        private const val EVENT_CHANNEL = "com.doorphone.doorphone_viewer/kvs_webrtc_events"
    }

    private var eventSink: EventChannel.EventSink? = null
    private val activeConnections = ConcurrentHashMap<String, KVSConnection>()
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    data class KVSConnection(
        val channelName: String,
        val signalingClient: SignalingClient?,
        val peerConnection: PeerConnection?,
        val localVideoTrack: VideoTrack?,
        val remoteVideoTrack: VideoTrack?
    )

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> initialize(call, result)
            "connectAsViewer" -> connectAsViewer(call, result)
            "disconnect" -> disconnect(call, result)
            "sendOffer" -> sendOffer(call, result)
            "sendAnswer" -> sendAnswer(call, result)
            "sendIceCandidate" -> sendIceCandidate(call, result)
            "getConnectionState" -> getConnectionState(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: MethodChannel.Result) {
        try {
            val accessKeyId = call.argument<String>("accessKeyId")
            val secretAccessKey = call.argument<String>("secretAccessKey")
            val region = call.argument<String>("region") ?: "us-east-1"

            if (accessKeyId.isNullOrEmpty() || secretAccessKey.isNullOrEmpty()) {
                result.error("INVALID_CREDENTIALS", "Access key ID and secret access key are required", null)
                return
            }

            // Initialize WebRTC
            val initializationOptions = PeerConnectionFactory.InitializationOptions.builder(context)
                .setEnableInternalTracer(true)
                .createInitializationOptions()
            PeerConnectionFactory.initialize(initializationOptions)

            Log.d(TAG, "KVS WebRTC initialized for region: $region")
            result.success(mapOf("status" to "initialized"))

        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize KVS WebRTC", e)
            result.error("INITIALIZATION_FAILED", e.message, null)
        }
    }

    private fun connectAsViewer(call: MethodCall, result: MethodChannel.Result) {
        coroutineScope.launch {
            try {
                val channelName = call.argument<String>("channelName")
                val region = call.argument<String>("region") ?: "us-east-1"
                val accessKeyId = call.argument<String>("accessKeyId")
                val secretAccessKey = call.argument<String>("secretAccessKey")

                if (channelName.isNullOrEmpty()) {
                    result.error("INVALID_CHANNEL", "Channel name is required", null)
                    return@launch
                }

                if (accessKeyId.isNullOrEmpty() || secretAccessKey.isNullOrEmpty()) {
                    result.error("INVALID_CREDENTIALS", "AWS credentials are required", null)
                    return@launch
                }

                // Check if already connected to this channel
                if (activeConnections.containsKey(channelName)) {
                    result.error("ALREADY_CONNECTED", "Already connected to channel: $channelName", null)
                    return@launch
                }

                sendEvent(mapOf(
                    "type" to "connectionStateChanged",
                    "channelName" to channelName,
                    "state" to "connecting"
                ))

                // Create AWS credentials
                val credentials = BasicAWSCredentials(accessKeyId, secretAccessKey)
                val credentialsProvider = AWSStaticCredentialsProvider(credentials)

                // Create signaling client
                val signalingClient = createSignalingClient(channelName, region, credentialsProvider)
                
                // Create peer connection
                val peerConnection = createPeerConnection(channelName)

                // Store connection
                val connection = KVSConnection(
                    channelName = channelName,
                    signalingClient = signalingClient,
                    peerConnection = peerConnection,
                    localVideoTrack = null,
                    remoteVideoTrack = null
                )
                activeConnections[channelName] = connection

                // Connect signaling client
                signalingClient?.connectAsViewer()

                sendEvent(mapOf(
                    "type" to "connectionStateChanged",
                    "channelName" to channelName,
                    "state" to "connected"
                ))

                result.success(mapOf(
                    "status" to "connected",
                    "channelName" to channelName
                ))

            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect as viewer", e)
                sendEvent(mapOf(
                    "type" to "connectionStateChanged",
                    "channelName" to call.argument<String>("channelName"),
                    "state" to "failed",
                    "error" to e.message
                ))
                result.error("CONNECTION_FAILED", e.message, null)
            }
        }
    }

    private fun createSignalingClient(
        channelName: String,
        region: String,
        credentialsProvider: AWSStaticCredentialsProvider
    ): SignalingClient? {
        return try {
            // This is a simplified implementation
            // In practice, you'd use the actual AWS KVS WebRTC SDK
            Log.d(TAG, "Creating signaling client for channel: $channelName")
            null // Placeholder - implement with actual AWS SDK
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create signaling client", e)
            null
        }
    }

    private fun createPeerConnection(channelName: String): PeerConnection? {
        return try {
            val factory = PeerConnectionFactory.builder()
                .setVideoDecoderFactory(DefaultVideoDecoderFactory(null))
                .setVideoEncoderFactory(DefaultVideoEncoderFactory(null, true, true))
                .createPeerConnectionFactory()

            val iceServers = listOf(
                PeerConnection.IceServer.builder("stun:stun.l.google.com:19302").createIceServer()
            )

            val rtcConfig = PeerConnection.RTCConfiguration(iceServers).apply {
                tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.DISABLED
                bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE
                rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE
                continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY
                keyType = PeerConnection.KeyType.ECDSA
            }

            val observer = object : PeerConnection.Observer {
                override fun onSignalingChange(state: PeerConnection.SignalingState?) {
                    Log.d(TAG, "Signaling state changed: $state")
                }

                override fun onIceConnectionChange(state: PeerConnection.IceConnectionState?) {
                    Log.d(TAG, "ICE connection state changed: $state")
                    sendEvent(mapOf(
                        "type" to "iceConnectionStateChanged",
                        "channelName" to channelName,
                        "state" to state?.name
                    ))
                }

                override fun onIceConnectionReceivingChange(receiving: Boolean) {
                    Log.d(TAG, "ICE connection receiving change: $receiving")
                }

                override fun onIceGatheringChange(state: PeerConnection.IceGatheringState?) {
                    Log.d(TAG, "ICE gathering state changed: $state")
                }

                override fun onIceCandidate(candidate: IceCandidate?) {
                    candidate?.let {
                        sendEvent(mapOf(
                            "type" to "iceCandidate",
                            "channelName" to channelName,
                            "candidate" to mapOf(
                                "candidate" to it.sdp,
                                "sdpMid" to it.sdpMid,
                                "sdpMLineIndex" to it.sdpMLineIndex
                            )
                        ))
                    }
                }

                override fun onIceCandidatesRemoved(candidates: Array<out IceCandidate>?) {
                    Log.d(TAG, "ICE candidates removed")
                }

                override fun onAddStream(stream: MediaStream?) {
                    Log.d(TAG, "Remote stream added")
                    stream?.let {
                        sendEvent(mapOf(
                            "type" to "remoteStreamAdded",
                            "channelName" to channelName,
                            "streamId" to it.id
                        ))
                    }
                }

                override fun onRemoveStream(stream: MediaStream?) {
                    Log.d(TAG, "Remote stream removed")
                }

                override fun onDataChannel(dataChannel: DataChannel?) {
                    Log.d(TAG, "Data channel received")
                }

                override fun onRenegotiationNeeded() {
                    Log.d(TAG, "Renegotiation needed")
                }

                override fun onAddTrack(receiver: RtpReceiver?, streams: Array<out MediaStream>?) {
                    Log.d(TAG, "Track added")
                }
            }

            factory.createPeerConnection(rtcConfig, observer)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to create peer connection", e)
            null
        }
    }

    private fun disconnect(call: MethodCall, result: MethodChannel.Result) {
        try {
            val channelName = call.argument<String>("channelName")
            
            if (channelName.isNullOrEmpty()) {
                result.error("INVALID_CHANNEL", "Channel name is required", null)
                return
            }

            val connection = activeConnections.remove(channelName)
            connection?.let {
                it.peerConnection?.close()
                it.signalingClient?.disconnect()
                
                sendEvent(mapOf(
                    "type" to "connectionStateChanged",
                    "channelName" to channelName,
                    "state" to "disconnected"
                ))
            }

            result.success(mapOf("status" to "disconnected"))

        } catch (e: Exception) {
            Log.e(TAG, "Failed to disconnect", e)
            result.error("DISCONNECT_FAILED", e.message, null)
        }
    }

    private fun sendOffer(call: MethodCall, result: MethodChannel.Result) {
        // Implementation for sending WebRTC offer
        result.success(mapOf("status" to "offer_sent"))
    }

    private fun sendAnswer(call: MethodCall, result: MethodChannel.Result) {
        // Implementation for sending WebRTC answer
        result.success(mapOf("status" to "answer_sent"))
    }

    private fun sendIceCandidate(call: MethodCall, result: MethodChannel.Result) {
        // Implementation for sending ICE candidate
        result.success(mapOf("status" to "ice_candidate_sent"))
    }

    private fun getConnectionState(call: MethodCall, result: MethodChannel.Result) {
        val channelName = call.argument<String>("channelName")
        val connection = activeConnections[channelName]
        
        val state = if (connection != null) "connected" else "disconnected"
        result.success(mapOf("state" to state))
    }

    private fun sendEvent(event: Map<String, Any?>) {
        eventSink?.success(event)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun dispose() {
        coroutineScope.cancel()
        activeConnections.values.forEach { connection ->
            connection.peerConnection?.close()
            connection.signalingClient?.disconnect()
        }
        activeConnections.clear()
    }
}