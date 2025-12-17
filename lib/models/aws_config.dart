class AWSConfig {
  final String region;
  final String iotEndpoint;
  final String kvsChannelArn;
  final String accessKeyId;
  final String secretAccessKey;
  final String? sessionToken;

  const AWSConfig({
    required this.region,
    required this.iotEndpoint,
    required this.kvsChannelArn,
    required this.accessKeyId,
    required this.secretAccessKey,
    this.sessionToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'iotEndpoint': iotEndpoint,
      'kvsChannelArn': kvsChannelArn,
      'accessKeyId': accessKeyId,
      'secretAccessKey': secretAccessKey,
      'sessionToken': sessionToken,
    };
  }

  factory AWSConfig.fromJson(Map<String, dynamic> json) {
    return AWSConfig(
      region: json['region'] as String,
      iotEndpoint: json['iotEndpoint'] as String,
      kvsChannelArn: json['kvsChannelArn'] as String,
      accessKeyId: json['accessKeyId'] as String,
      secretAccessKey: json['secretAccessKey'] as String,
      sessionToken: json['sessionToken'] as String?,
    );
  }

  AWSConfig copyWith({
    String? region,
    String? iotEndpoint,
    String? kvsChannelArn,
    String? accessKeyId,
    String? secretAccessKey,
    String? sessionToken,
  }) {
    return AWSConfig(
      region: region ?? this.region,
      iotEndpoint: iotEndpoint ?? this.iotEndpoint,
      kvsChannelArn: kvsChannelArn ?? this.kvsChannelArn,
      accessKeyId: accessKeyId ?? this.accessKeyId,
      secretAccessKey: secretAccessKey ?? this.secretAccessKey,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AWSConfig &&
        other.region == region &&
        other.iotEndpoint == iotEndpoint &&
        other.kvsChannelArn == kvsChannelArn &&
        other.accessKeyId == accessKeyId &&
        other.secretAccessKey == secretAccessKey &&
        other.sessionToken == sessionToken;
  }

  @override
  int get hashCode {
    return Object.hash(
      region,
      iotEndpoint,
      kvsChannelArn,
      accessKeyId,
      secretAccessKey,
      sessionToken,
    );
  }
}