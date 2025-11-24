import { supabase } from "../supabase";


// Check if user is a member of the organisation
export async function isUserInOrganization(userId: string, orgId: string): Promise<boolean> {
  const { data, error } = await supabase
    .from("user_role")
    .select("role")
    .eq("userid", userId)
    .eq("orgid", orgId)
    .single();

  if (error || !data) return false;
  return true;
}

// Get the user's role (from user_roles table)
export async function getUserRole(userId: string): Promise<{ role: number } | null> {
  const { data, error } = await supabase
    .from("user_role")
    .select("role")
    .eq("userid", userId)
    .single();

  if (error || !data) return null;
  return data;
}
