import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, SafeAreaView, StyleSheet } from 'react-native';
import { authenticateBiometrically, checkDeviceSupport } from '../services/biometrics';

const LoginScreen = () => {
  const [biometricsSupported, setBiometricsSupported] = useState(false);

  useEffect(() => {
    (async () => {
      const supported = await checkDeviceSupport();
      setBiometricsSupported(supported);
    })();
  }, []);

  const handleBiometricLogin = async () => {
    const result = await authenticateBiometrically();
    if (result.success) {
      alert('Authenticated Successfully! Redirecting to Dashboard...');
      // Navigation logic here
    } else {
      alert(`Authentication failed: ${result.error}`);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>🗳️ Online Voting</Text>
        <Text style={styles.subtitle}>Secure Campus Elections</Text>

        <View style={styles.form}>
          {/* Standard login fields would go here */}
          <TouchableOpacity style={styles.button}>
            <Text style={styles.buttonText}>Login with ID</Text>
          </TouchableOpacity>

          {biometricsSupported && (
            <TouchableOpacity 
              onPress={handleBiometricLogin}
              style={[styles.button, styles.biometricButton]}
            >
              <Text style={styles.buttonText}>🔑 Use FaceID / TouchID</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0f172a', // Dark theme matching web
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#f8fafc',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    color: '#94a3b8',
    textAlign: 'center',
    marginBottom: 48,
  },
  form: {
    gap: 16,
  },
  button: {
    backgroundColor: '#3b82f6',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  biometricButton: {
    backgroundColor: '#1e293b',
    borderWidth: 1,
    borderColor: '#334155',
    marginTop: 8,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default LoginScreen;
