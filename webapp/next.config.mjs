/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    // Make environment variables available at build time
    WEBSOCKET_SERVER_URL: process.env.WEBSOCKET_SERVER_URL || 'http://localhost:8081',
  },
  // Expose environment variables to the browser 
  publicRuntimeConfig: {
    WEBSOCKET_SERVER_URL: process.env.NEXT_PUBLIC_WEBSOCKET_SERVER_URL || 'http://localhost:8081',
  },
};

export default nextConfig;
