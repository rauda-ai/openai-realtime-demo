import { hasTwilioCredentials, ENABLE_TWILIO } from "@/lib/config";

export async function GET() {
  // Check both that credentials are set and that Twilio is enabled
  return Response.json({ 
    credentialsSet: hasTwilioCredentials,
    twilioEnabled: ENABLE_TWILIO
  });
}
