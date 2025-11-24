import type { Organisation } from "@/types/database.type";
import { supabase } from "../supabase"
import { uploadFile } from "./spaces.controller";

// Remove direct joining - now users must send requests
export const joinOrganisation = async (userId: string, organisationId: string, role: number) => {
    const { error } = await supabase
      .from("user_role")
      .insert([{ userid: userId, orgid: organisationId, role }]);

    if (error) throw error;
    return { success: true };
  };

export const checkUserMembership = async (userId: string, organisationId: string) => {
  const { data, error } = await supabase
    .from("user_role")
    .select("role")
    .eq("user_id", userId)
    .eq("organisation_id", organisationId)
    .single();

  if (error && error.code !== 'PGRST116') throw error; // PGRST116 is "not found"
  return data;
};
  
  export const getUserOrganisations = async (userId: string) => {
    const { data, error } = await supabase
      .from("user_role")
      .select("orgid, organisations(*)")
      .eq("userid", userId);

    if (error) throw error;
    return data;
  };
  
  export const leaveOrganisation = async (userId: string, organisationId: string) => {
    const { error } = await supabase
      .from("user_role")
      .delete()
      .eq("userid", userId)
      .eq("orgid", organisationId);

    if (error) throw error;
    return { success: true };
  };

  export const createOrganisation = async (userId: string, organisationName: string, description: string, type: "Educational" | "CoWorking", file:{filePath:string, fileData:string, fileType:string}, roles: {name:string, priviledges:number}[]): Promise<{ data: Organisation | null; error: string | null }> => {

    let fileurl = null;
    if(file.filePath !== "" && file.fileData !== "" && file.fileType !== ""){
      fileurl = await uploadFile({...file, table: "organisations"});
    }
    const { data, error } = await supabase
      .from("organisations")
      .insert([{ ownerid: userId, name: organisationName, description, type, logo: fileurl }])
      .select()
      .single();

    if (!error && data?.id) {
      const { error: updateError } = await supabase
      .from("users")
      .update({ orgid: data.id })
      .eq("id", userId);

      if (updateError) {
        return { data: null, error: updateError.message };
      }

      // Insert roles including Owner
      const { error: roleInsertError } = await supabase
        .from("roles")
        .insert([...roles.map(role => ({ ...role, orgid: data.id })), { name: 'Owner', priviledges: 7, orgid: data.id }]);
      if (roleInsertError) {
        return { data: null, error: roleInsertError.message };
      }

      // Fetch the Owner role for this organisation
      const { data: roleData, error: roleFetchError } = await supabase
        .from("roles")
        .select("*")
        .eq("name", "Owner")
        .eq("orgid", data.id)
        .single();
      if (roleFetchError) {
        return { data: null, error: roleFetchError.message };
      }
      
      const { data: userRoleData, error: userRoleError} = await supabase.from("user_role").insert([{ userid:userId, role:roleData?.id, orgid: data.id }]);

      if (userRoleError) {
        return { data: null, error: userRoleError.message };
      }
    }
    if (error) {
      return { data: null, error: error.message };
    }

    return { data, error: null };
  }

  export const searchOrganisations = async (query: string): Promise<{ data: Organisation[] | null; error: string | null }> => {
    const { data, error } = await supabase
      .from("organisations")
      .select("*")
      .ilike("name", `%${query}%`)
      .limit(10);
    if (error) {
      return { data: null, error: error.message };
    }
    return { data, error: null };
  }

  export const getOrganisationById = async (organisationId: string): Promise<{ data: Organisation | null; error: string | null }> => {
    const { data, error } = await supabase
      .from("organisations")
      .select("*")
      .eq("id", organisationId)
      .single();
    if (error) {
      return { data: null, error: error.message };
    }
    return { data, error: null };
  }

  // get Organisation by user id
  export const getOrganisationByUserId = async (userId: string): Promise<{ data: Organisation | null; error: string | null }> => {
    // First, get organisation IDs where user is a member
    const { data: userRoles, error: userRoleError } = await supabase
      .from("user_role")
      .select("orgid, role")
      .eq("userid", userId).single();

    if (userRoleError) {
      return { data: null, error: userRoleError.message };
    }

  

    // Then, fetch organisations by those IDs
    const { data, error } = await supabase
      .from("organisations")
      .select("*, roles(*)")
      .eq("id", userRoles.orgid)
      .eq("roles.id", userRoles.role)
      .single();
    if (error) {
      return { data: null, error: error.message };
    }
    return { data:{...data, ...userRoles}, error: null };
  }