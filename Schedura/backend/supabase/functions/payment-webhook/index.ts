// supabase/functions/payment-webhook/index.ts
//@ts-nocheck
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createHmac } from 'https://deno.land/std@0.168.0/node/crypto.ts'

serve(async (req) => {
  try {
    const body = await req.json()
    const signature = req.headers.get('x-webhook-signature')
    
    // Verify webhook signature (for security)
    const expectedSignature = createHmac('sha256', Deno.env.get('WEBHOOK_SECRET') ?? '')
      .update(JSON.stringify(body))
      .digest('hex')
    
    if (signature !== expectedSignature) {
      return new Response('Invalid signature', { status: 401 })
    }
    
    const { transactionId, status, utr } = body
    
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Update payment status
    const { error } = await supabaseClient
      .from('payments')
      .update({
        status: status,
        utr: utr,
        updated_at: new Date().toISOString()
      })
      .eq('transaction_id', transactionId)
    
    if (error) throw error
    
    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})