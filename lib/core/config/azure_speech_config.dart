/// Azure Speech Service Configuration
/// 
/// Note: In production, these values should be stored securely
/// (e.g., environment variables, secure storage, or backend service)
class AzureSpeechConfig {
  // TODO: Replace with your Azure Speech Service subscription key
  static const String subscriptionKey = '';
  
  // TODO: Replace with your Azure Speech Service region
  // Examples: 'eastus', 'westus', 'southeastasia', etc.
  static const String region = '';
  
  // Azure TTS REST API endpoint
  static String get ttsEndpoint => '';
  
  // Audio format: audio-16khz-128kbitrate-mono-mp3
  static const String audioFormat = 'audio-16khz-128kbitrate-mono-mp3';
}

