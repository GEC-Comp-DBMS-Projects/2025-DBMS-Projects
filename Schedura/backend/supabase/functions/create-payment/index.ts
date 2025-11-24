// supabase/functions/create-payment/index.ts
//@ts-nocheck

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { amount, userId, description, upiId } = await req.json()
    
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Generate unique transaction ID
    const transactionId = `TXN${Date.now()}${Math.random().toString(36).substr(2, 9)}`
    
    // Insert payment record
    const { data, error } = await supabaseClient
      .from('payments')
      .insert({
        transaction_id: transactionId,
        user_id: userId,
        amount: amount,
        status: 'pending',
        upi_id: upiId
      })
      .select()
      .single()
    
    if (error) throw error
    
    return new Response(
      JSON.stringify({
        success: true,
        transactionId,
        upiId: upiId,
        amount,
        paymentId: data.id
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})