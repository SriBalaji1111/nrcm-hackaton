import * as LocalAuthentication from 'expo-local-authentication';
import { Alert } from 'react-native';

export const checkDeviceSupport = async () => {
  const compatible = await LocalAuthentication.hasHardwareAsync();
  const enrolled = await LocalAuthentication.isEnrolledAsync();
  return compatible && enrolled;
};

export const authenticateBiometrically = async () => {
  try {
    const isSupported = await checkDeviceSupport();
    if (!isSupported) {
      return { success: false, error: 'Biometrics not supported or enrolled' };
    }

    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate to cast your vote',
      fallbackLabel: 'Enter Password',
      disableDeviceFallback: false,
    });

    if (result.success) {
      return { success: true };
    } else {
      return { success: false, error: result.error };
    }
  } catch (error) {
    console.error('Biometric Auth Error:', error);
    return { success: false, error: 'Authentication failed' };
  }
};
