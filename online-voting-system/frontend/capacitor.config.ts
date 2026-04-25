import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.electa.app',
  appName: 'electa',
  webDir: 'out', // Next.js static export directory
  bundledWebRuntime: false,
  server: {
    url: 'https://electaa.vercel.app',
    cleartext: true
  }
};

export default config;
