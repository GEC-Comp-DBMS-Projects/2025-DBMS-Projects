import type { JoinRequest } from "@/types/database.type";
import { supabase } from "../supabase";

export const createJoinRequest = async (
  userId: string, 
  organisationId: string, 
  message?: string,
) => {
  // Check if user already has a pending request
  const { data: existingRequest } = await supabase
    .from("join_requests")
    .select("*")
    .eq("user_id", userId)
    .eq("organisation_id", organisationId)
    .eq("status", "pending")
    .single();

  if (existingRequest) {
    throw new Error("You already have a pending request for this organization");
  }

  // Check if user is already a member
  const { data: existingMember } = await supabase
    .from("user_role")
    .select("*")
    .eq("userid", userId)
    .eq("orgid", organisationId)
    .single();

  if (existingMember) {
    throw new Error("You are already a member of this organization");
  }

  const { data, error } = await supabase
    .from("join_requests")
    .insert([{ 
      user_id: userId, 
      organisation_id: organisationId, 
      message,
      status: "pending"
    }])
    .select()
    .single();

  if (error) throw error;
  return data;
};

export const getOrganisationJoinRequests = async (organisationId: string, ownerId: string) => {
  // First verify the user is the owner of the organization
  const { data: org } = await supabase
    .from("organisations")
    .select("ownerid")
    .eq("id", organisationId)
    .eq("ownerid", ownerId)
    .single();

  if (!org) {
    throw new Error("Unauthorized: Only organization owners can view join requests");
  }

  const { data, error } = await supabase
    .from("join_requests")
    .select(`
      *,
      users (
        id,
        name,
        email
      )
    `)
    .eq("organisation_id", organisationId)
    .eq("status", "pending")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
};

export const approveJoinRequest = async (
  requestId: string, 
  ownerId: string, 
  assignedRole:number
) => {
  // Get the join request details
  const { data: request, error: requestError } = await supabase
    .from("join_requests")
    .select(`
      *,
      organisations!inner (
        ownerid
      )
    `)
    .eq("id", requestId)
    .eq("status", "pending")
    .single();

  if (requestError || !request) {
    throw new Error("Join request not found or already processed");
  }

  // Verify the user is the owner
  if (request.organisations.ownerid !== ownerId) {
    throw new Error("Unauthorized: Only organization owners can approve join requests");
  }

  // Add user to organization
  const { error: addError } = await supabase
    .from("user_role")
    .insert([{ 
      userid: request.user_id, 
      orgid: request.organisation_id,
      role: assignedRole
    }]);

  if (addError) throw addError;

  // Update request status
  const { error: updateError } = await supabase
    .from("join_requests")
    .update({ 
      status: "approved",
      updated_at: new Date().toISOString()
    })
    .eq("id", requestId);

  if (updateError) throw updateError;

  return { success: true };
};

export const rejectJoinRequest = async (requestId: string, ownerId: string) => {
  // Get the join request details
  const { data: request, error: requestError } = await supabase
    .from("join_requests")
    .select(`
      *,
      organisations!inner (
        ownerid
      )
    `)
    .eq("id", requestId)
    .eq("status", "pending")
    .single();

  if (requestError || !request) {
    throw new Error("Join request not found or already processed");
  }

  // Verify the user is the owner
  if (request.organisations.ownerid !== ownerId) {
    throw new Error("Unauthorized: Only organization owners can reject join requests");
  }

  // Update request status
  const { error } = await supabase
    .from("join_requests")
    .update({ 
      status: "rejected",
      updated_at: new Date().toISOString()
    })
    .eq("id", requestId);

  if (error) throw error;

  return { success: true };
};

export const getUserJoinRequests = async (userId: string) => {
  const { data, error } = await supabase
    .from("join_requests")
    .select(`
      *,
      organisations (
        id,
        name,
        description,
        type,
        logo
      )
    `)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
};