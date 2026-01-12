enum VoiceGender {
  male,
  female;

  static VoiceGender fromString(String value) {
    return VoiceGender.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => VoiceGender.female,
    );
  }

  @override
  String toString() {
    return name;
  }
}

enum VoiceAge {
  kid,
  young,
  adult,
  senior;

  static VoiceAge fromString(String value) {
    return VoiceAge.values.firstWhere(
      (e) => e.toString().split('.').last == value.toLowerCase(),
      orElse: () => VoiceAge.adult,
    );
  }

  @override
  String toString() {
    return name;
  }
}

class VoiceConfig {
  final VoiceGender gender;
  final VoiceAge age;
  final String languageCode;
  final double rate; // 0.5 - 2.0, default: 1.0
  final double pitch; // -50 to +50 semitones, default: 0.0

  VoiceConfig({
    required this.gender,
    required this.age,
    this.languageCode = 'en-US',
    this.rate = 1.0,
    this.pitch = 0.0,
  });

  factory VoiceConfig.fromMap(Map<String, dynamic> map) {
    return VoiceConfig(
      gender: VoiceGender.fromString(map['gender'] ?? 'female'),
      age: VoiceAge.fromString(map['age'] ?? 'adult'),
      languageCode: map['languageCode'] ?? 'en-US',
      rate: (map['rate'] ?? 1.0).toDouble(),
      pitch: (map['pitch'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender.toString(),
      'age': age.toString(),
      'languageCode': languageCode,
      'rate': rate,
      'pitch': pitch,
    };
  }

  /// Map gender + age + languageCode to Azure Neural Voice name
  String toAzureVoiceName() {
    // Azure Neural Voices mapping for en-US
    if (languageCode.startsWith('en-US')) {
      if (gender == VoiceGender.female) {
        switch (age) {
          case VoiceAge.kid:
            return 'en-US-JennyNeural'; // Kid female (using Jenny as young voice)
          case VoiceAge.young:
            return 'en-US-JennyNeural'; // Young female
          case VoiceAge.adult:
            return 'en-US-AriaNeural'; // Adult female
          case VoiceAge.senior:
            return 'en-US-AriaNeural'; // Senior female (using Aria as mature voice)
        }
      } else {
        // male
        switch (age) {
          case VoiceAge.kid:
            return 'en-US-GuyNeural'; // Kid male (using Guy as young voice)
          case VoiceAge.young:
            return 'en-US-GuyNeural'; // Young male
          case VoiceAge.adult:
            return 'en-US-RogerNeural'; // Adult male
          case VoiceAge.senior:
            return 'en-US-RogerNeural'; // Senior male
        }
      }
    }

    // Default fallback (can be extended for other languages)
    return 'en-US-JennyNeural';
  }

  @override
  String toString() {
    return 'VoiceConfig(gender: $gender, age: $age, languageCode: $languageCode, rate: $rate, pitch: $pitch)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceConfig &&
        other.gender == gender &&
        other.age == age &&
        other.languageCode == languageCode &&
        other.rate == rate &&
        other.pitch == pitch;
  }

  @override
  int get hashCode {
    return Object.hash(gender, age, languageCode, rate, pitch);
  }
}

