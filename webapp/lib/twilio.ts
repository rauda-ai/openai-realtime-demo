import "server-only";
import twilio from "twilio";
import { TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, hasTwilioCredentials, ENABLE_TWILIO } from "./config";

// Log the credentials status for debugging
if (!hasTwilioCredentials) {
  console.warn("Twilio credentials not set. Twilio client will be disabled.");
} else if (!ENABLE_TWILIO) {
  console.warn("Twilio is disabled via configuration. Twilio client will be disabled.");
}

// Create the client if credentials are available and Twilio is enabled
export const twilioClient = 
  hasTwilioCredentials && ENABLE_TWILIO 
    ? twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN) 
    : null;

export default twilioClient;
