// backend/server.js
import express from "express";
import axios from "axios";
import dotenv from "dotenv";
import cors from "cors";
import dayjs from "dayjs";
import { createClient } from '@supabase/supabase-js';
import crypto from "crypto";
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Google OAuth / Calendar env
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = process.env.REDIRECT_URI; // e.g. https://api.example.com/integrations/google/callback

// Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

// Razorpay env
const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID;
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET;

// -----------------------
// Existing Google integration endpoints (connect/callback/disconnect/status)
// -----------------------

// Step 1 - Generate Google OAuth URL
app.get("/integrations/google/connect", (req, res) => {
  const { userid } = req.query;
  if (!userid) return res.status(400).send("Please provide user id");
  const scopes = [
    "https://www.googleapis.com/auth/calendar.events",
    "https://www.googleapis.com/auth/calendar",
  ].join(" ");

  // Use state to pass userid through redirect
  const authUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(
    REDIRECT_URI
  )}&response_type=code&scope=${encodeURIComponent(
    scopes
  )}&access_type=offline&prompt=consent&state=${encodeURIComponent(userid)}`;

  res.json({ url: authUrl });
});

// Step 2 - Handle Google redirect
app.get("/integrations/google/callback", async (req, res) => {
  const { code, state } = req.query;
  const userid = state;
  if (!code || !userid) return res.status(400).send("Missing authorization code or user id.");

  try {
    const tokenRes = await axios.post("https://oauth2.googleapis.com/token", null, {
      params: {
        code,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri: REDIRECT_URI,
        grant_type: "authorization_code",
      }
    });

    const { refresh_token } = tokenRes.data;

    // Check if integration record exists
    const { data: existingRecord } = await supabase
      .from("user_integrations")
      .select("*")
      .eq("user_id", userid)
      .eq("provider", "google")
      .single();

    if (existingRecord) {
      // Update existing record
      await supabase.from("user_integrations").update({
        connected: true,
        refresh_token,
        updated_at: new Date().toISOString()
      }).eq("user_id", userid).eq("provider", "google");
    } else {
      // Insert new record
      await supabase.from("user_integrations").insert([{
        user_id: userid,
        provider: "google",
        connected: true,
        refresh_token,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }]);
    }

    return res.send(
      "<h2>✅ Google Calendar connected successfully! You can close this window now.</h2>"
    );
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).send("Failed to exchange token.");
  }
});

// Step 3 - Disconnect Google
app.post("/integrations/google/disconnect", async (req, res) => {
  const { userid } = req.query;
  if (!userid) return res.status(400).json({ error: "Missing user id" });

  await supabase.from("user_integrations").update({
    connected: false,
    refresh_token: null,
    updated_at: new Date().toISOString()
  }).eq("user_id", userid).eq("provider", "google");

  res.json({ success: true });
});

// Step 4 - Check integration status
app.get("/integrations/status", async (req, res) => {
  const { userid } = req.query;
  if (!userid) return res.status(400).json({ error: "Missing user id" });
  const { data, error } = await supabase
    .from("user_integrations")
    .select("connected")
    .eq("user_id", userid)
    .eq("provider", "google")
    .single();
  res.json({
    google: !!data?.connected,
  });
});

// Step 5 - Refresh access token using stored refresh_token (for calendar add)
async function getAccessToken(refresh_token) {
  const tokenRes = await axios.post("https://oauth2.googleapis.com/token", null, {
    params: {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      refresh_token,
      grant_type: "refresh_token",
    }
  });
  return tokenRes.data.access_token;
}

// Step 6 - Create Google Calendar Event
app.post("/calendar/add", async (req, res) => {
  try {
    const { userid, title, description, startTime, endTime } = req.body;
    if (!userid) return res.status(400).json({ error: "Missing user id" });

    // Get integration record
    const { data: integration } = await supabase
      .from("user_integrations")
      .select("*")
      .eq("user_id", userid)
      .eq("provider", "google")
      .single();

    if (!integration || !integration.connected || !integration.refresh_token) {
      return res.status(400).json({ error: "Google Calendar not connected" });
    }

    const accessToken = await getAccessToken(integration.refresh_token);

    const event = {
      summary: title,
      description,
      start: { dateTime: dayjs(startTime).toISOString(), timeZone: "Asia/Kolkata" },
      end: { dateTime: dayjs(endTime).toISOString(), timeZone: "Asia/Kolkata" },
    };

    const googleRes = await axios.post(
      "https://www.googleapis.com/calendar/v3/calendars/primary/events",
      event,
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    res.json({ success: true, eventId: googleRes.data.id });
  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: "Failed to create event" });
  }
});

// -----------------------
// New: Payments endpoints (Razorpay order creation & verification + optional transfer)
// -----------------------

// Helper: create Razorpay order via REST (uses basic auth)
async function createRazorpayOrder(amountInPaise, receipt) {
  const url = "https://api.razorpay.com/v1/orders";
  const payload = {
    amount: amountInPaise,
    currency: "INR",
    receipt,
    payment_capture: 1
  };
  const auth = {
    username: RAZORPAY_KEY_ID,
    password: RAZORPAY_KEY_SECRET
  };
  const response = await axios.post(url, payload, { auth });
  return response.data;
}

// POST /payments/create-order
// body: { bookingId, ownerId, amount }  -> returns { key_id, order_id, amount }
app.post("/payments/create-order", async (req, res) => {
  try {
    const { bookingId, ownerId, amount } = req.body;
    if (!bookingId || !ownerId || !amount) {
      return res.status(400).json({ error: "bookingId, ownerId and amount are required" });
    }

    // convert to paise
    const amountInPaise = Math.round(Number(amount) * 100);
    const receipt = `receipt_${bookingId}_${Date.now()}`;

    const order = await createRazorpayOrder(amountInPaise, receipt.slice(0,40));

    // Store order metadata in payments table
    await supabase.from("payments").insert([{
      booking_id: bookingId,
      owner_id: ownerId,
      order_id: order.id,
      amount: amountInPaise,
      currency: order.currency,
      status: "created",
      created_at: new Date().toISOString()
    }]);

    res.json({
      key_id: RAZORPAY_KEY_ID,
      order_id: order.id,
      amount: amount, // original amount in INR
    });
  } catch (err) {
    console.error("create-order error:", err.response?.data || err.message);
    res.status(500).json({ error: "Failed to create order" });
  }
});

// POST /payments/verify
// body: { bookingId, order_id, payment_id, signature }
app.post("/payments/verify", async (req, res) => {
  try {
    const { bookingId, order_id, payment_id, signature } = req.body;
    if (!bookingId || !order_id || !payment_id || !signature) {
      return res.status(400).json({ error: "Missing parameters" });
    }

    // Verify signature
    const generatedSignature = crypto.createHmac('sha256', RAZORPAY_KEY_SECRET)
      .update(`${order_id}|${payment_id}`)
      .digest('hex');

    if (generatedSignature !== signature) {
      // mark payment as failed in DB
      await supabase.from("payments").update({ status: "signature_mismatch", updated_at: new Date().toISOString() })
        .eq("order_id", order_id);
      return res.status(400).json({ success: false, error: "Signature verification failed" });
    }

    // mark payment as paid
    const updateRes = await supabase.from("payments").update({
      status: "paid",
      payment_id,
      updated_at: new Date().toISOString()
    }).eq("order_id", order_id);

    // Fetch payment record to know amount/owner
    const { data: paymentRecord } = await supabase
      .from("payments")
      .select("*")
      .eq("order_id", order_id)
      .single();

    // Attempt transfer to owner if owner has razorpay_account_id
    if (paymentRecord) {
      const ownerId = paymentRecord.owner_id;
      const amountInPaise = paymentRecord.amount; // already in paise
      try {
        // Try to get owner's razorpay account id (linked account) from users table
        const { data: ownerRow } = await supabase
          .from("users")
          .select("razorpay_account_id")
          .eq("id", ownerId)
          .single();

        const ownerAccountId = ownerRow?.razorpay_account_id;

        if (ownerAccountId) {
          // Create a transfer using Razorpay Transfers API
          // Note: transfers require that your Razorpay account has payouts/transfers enabled and the owner is onboarded
          const transferPayload = {
            transfers: [
              {
                account: ownerAccountId,
                amount: amountInPaise, // paise
                currency: "INR",
                notes: {
                  booking_id: bookingId,
                  payment_id
                }
              }
            ]
          };

          const transferRes = await axios.post("https://api.razorpay.com/v1/transfers", transferPayload, {
            auth: {
              username: RAZORPAY_KEY_ID,
              password: RAZORPAY_KEY_SECRET
            }
          });

          // record transfer in DB
          await supabase.from("payments").update({
            transfer_status: "transferred",
            transfer_response: transferRes.data,
            updated_at: new Date().toISOString()
          }).eq("order_id", order_id);
        } else {
          // owner not onboarded; record note
          await supabase.from("payments").update({
            transfer_status: "owner_not_onboarded",
            updated_at: new Date().toISOString()
          }).eq("order_id", order_id);
        }
      } catch (transferErr) {
        console.error("Transfer error:", transferErr.response?.data || transferErr.message);
        // record transfer failure
        await supabase.from("payments").update({
          transfer_status: "transfer_failed",
          transfer_response: JSON.stringify(transferErr.response?.data || transferErr.message),
          updated_at: new Date().toISOString()
        }).eq("order_id", order_id);
      }
    }

    // Optionally, mark booking as paid/confirmed here or let client call accept flow
    res.json({ success: true });
  } catch (err) {
    console.error("verify error:", err.response?.data || err.message);
    res.status(500).json({ success: false, error: "Verification error" });
  }
});

// -----------------------
// Keep previous server behavior (if any other endpoints exist)
// -----------------------

app.listen(5000, () =>
  console.log("✅ Backend running on http://localhost:5000")
);
