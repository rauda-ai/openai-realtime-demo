// Environment configuration for the application
import getConfig from 'next/config';

// Get static config values from next.config.mjs
// These were set at build time
const { publicRuntimeConfig, serverRuntimeConfig } = getConfig() || { 
  publicRuntimeConfig: {}, 
  serverRuntimeConfig: {} 
};

// Helper function to get values with fallbacks
const getConfigValue = (
  serverVar: string, 
  publicVar?: string, 
  defaultValue: string = ''
): string => {
  // For server-side values
  if (typeof window === 'undefined') {
    return (
      // Check server runtime config (from next.config.mjs)
      serverRuntimeConfig[serverVar] ||
      // Check process.env as fallback
      process.env[serverVar] ||
      // Use default as last resort
      defaultValue
    );
  }
  
  // For client-side values  
  return (
    // Check public runtime config (from next.config.mjs)
    publicRuntimeConfig[publicVar || ''] ||
    // Check window.__NEXT_DATA__ from server-side props
    ((window as any).__NEXT_DATA__?.props?.pageProps?.[publicVar || '']) ||
    // Check process.env (client-side env vars)
    (publicVar ? process.env[publicVar] : null) ||
    // Use default
    defaultValue
  );
};

// === Public URLs (available on client-side) === 
export const WEBSOCKET_SERVER_URL = getConfigValue(
  'WEBSOCKET_SERVER_URL',
  'NEXT_PUBLIC_WEBSOCKET_SERVER_URL', 
  'http://localhost:8081'
);

// For WebSocket connections, use wss:// protocol for https and ws:// for http
export const getWebSocketURL = () => {
  if (!WEBSOCKET_SERVER_URL) return 'ws://localhost:8081';
  // Replace http:// with ws:// and https:// with wss://
  return WEBSOCKET_SERVER_URL.replace(/^http/, 'ws');
};

// === Server-only credentials ===
// These are only accessible on the server side
export const TWILIO_ACCOUNT_SID = getConfigValue('TWILIO_ACCOUNT_SID');
export const TWILIO_AUTH_TOKEN = getConfigValue('TWILIO_AUTH_TOKEN');
export const TWILIO_WEBHOOK_URL = getConfigValue('TWILIO_WEBHOOK_URL');

// Check if Twilio credentials are configured
export const hasTwilioCredentials = Boolean(TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN);

// === Feature flags ===
export const ENABLE_TWILIO = getConfigValue('ENABLE_TWILIO', 'NEXT_PUBLIC_ENABLE_TWILIO', 'true') === 'true';