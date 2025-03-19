/** @type {import('next').NextConfig} */
const nextConfig = {
  // Server-side only variables (not exposed to the browser)
  serverRuntimeConfig: {
    // API credentials (server-side only)
    TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID || '',
    TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN || '',
    TWILIO_WEBHOOK_URL: process.env.TWILIO_WEBHOOK_URL || '',
    
    // Server connection URLs (not public) - for internal service communication
    // In Docker, this should be the internal service name
    WEBSOCKET_SERVER_URL: process.env.WEBSOCKET_SERVER_URL || 'http://websocket-server:8081',
    
    // Feature flags (server-side)
    ENABLE_TWILIO: process.env.ENABLE_TWILIO || 'true',
  },
  
  // Expose these variables to the browser
  publicRuntimeConfig: {
    // Public URLs - for browser to server communication
    // This should be the public-facing URL that browsers can access
    NEXT_PUBLIC_WEBSOCKET_SERVER_URL: process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL || 'https://realtime.sandbox.rauda.ai',
    
    // Public feature flags
    NEXT_PUBLIC_ENABLE_TWILIO: process.env.NEXT_PUBLIC_ENABLE_TWILIO || 'true',
  },
  
  // Make process.env variables available in the browser
  // Can be accessed using process.env.VARIABLE_NAME
  env: {
    // Public environment variables for legacy components
    NEXT_PUBLIC_WEBSOCKET_SERVER_URL: process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL || 'https://realtime.sandbox.rauda.ai',
    NEXT_PUBLIC_ENABLE_TWILIO: process.env.NEXT_PUBLIC_ENABLE_TWILIO || 'true',
  }
};

export default nextConfig;
