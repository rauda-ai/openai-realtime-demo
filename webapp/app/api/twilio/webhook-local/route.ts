import { TWILIO_WEBHOOK_URL } from "@/lib/config";

export async function GET() {
  return Response.json({ webhookUrl: TWILIO_WEBHOOK_URL });
}
