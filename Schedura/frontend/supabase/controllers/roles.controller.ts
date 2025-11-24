import { supabase } from "../supabase";


/**
 * Add a new role to the roles table
 * @param orgid - Organization ID (reference to organisations table)
 * @param name - Role name
 * @param priviledges - Priviledges value (bitwise combination)
 * @returns The created role or error
 */
export const addRole = async (
  orgid: string,
  name: string,
  priviledges: number
) => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .insert([
        {
          orgid,
          name,
          priviledges: priviledges, // Note: using 'priviledges' to match your schema spelling
        },
      ])
      .select()
      .single();

    if (error) {
      throw error;
    }

    return { success: true, data };
  } catch (error) {
    console.error('Error adding role:', error);
    return { success: false, error };
  }
};

/**
 * Get all roles for an organization
 * @param orgid - Organization ID
 * @returns Array of roles or error
 */
export const getRolesByOrg = async (orgid: string) => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .select('*')
      .eq('orgid', orgid);

    if (error) {
      throw error;
    }

    return { success: true, data };
  } catch (error) {
    console.error('Error fetching roles:', error);
    return { success: false, error };
  }
};

/**
 * Update a role
 * @param roleId - Role ID
 * @param updates - Object containing fields to update
 * @returns Updated role or error
 */
export const updateRole = async (
  roleId: string,
  updates: { name?: string; priviledges?: number }
) => {
  try {
    const { data, error } = await supabase
      .from('roles')
      .update(updates)
      .eq('id', roleId)
      .select()
      .single();

    if (error) {
      throw error;
    }

    return { success: true, data };
  } catch (error) {
    console.error('Error updating role:', error);
    return { success: false, error };
  }
};

/**
 * Delete a role
 * @param roleId - Role ID
 * @returns Success status or error
 */
export const deleteRole = async (roleId: string) => {
  try {
    const { error } = await supabase.from('roles').delete().eq('id', roleId);

    if (error) {
      throw error;
    }

    return { success: true };
  } catch (error) {
    console.error('Error deleting role:', error);
    return { success: false, error };
  }
};

/**
 * Check if a role has a specific privilege
 * @param priviledges - The priviledges number from the role
 * @param privilegeValue - The privilege value to check (e.g., 1, 2, 4, 8, etc.)
 * @returns boolean indicating if the privilege exists
 */
export const hasPrivilege = (priviledges: number, privilegeValue: number): boolean => {
  return (priviledges & privilegeValue) === privilegeValue;
};

/**
 * Example usage in the modal:
 * 
 * import { addRole } from './controllers/rolesController';
 * 
 * const handleSubmit = async () => {
 *   const privilegeValue = calculatePrivilegeValue();
 *   const result = await addRole(orgid, roleName, privilegeValue);
 *   
 *   if (result.success) {
 *     console.log('Role created:', result.data);
 *     // Reset form and close modal
 *     setRoleName('');
 *     setSelectedPriviledges([]);
 *     setVisible(false);
 *   } else {
 *     console.error('Failed to create role:', result.error);
 *     // Show error message to user
 *   }
 * };
 */

export async function getRole(roleid: number): Promise<{ id: number; [key: string]: any } | null> {
  const { data, error } = await supabase
    .from("roles")
    .select("*")
    .eq("id", roleid)
    .single();

  if (error || !data) return null;
  return data;
}

// get roles belonging to an organisation
export async function getOrganisationRoles(orgid: string): Promise<Array<{ id: number; [key: string]: any }>> {
  const { data, error } = await supabase
    .from("roles")
    .select("*")
    .eq("orgid", orgid);

  if (error || !data) return [];
  return data;
}