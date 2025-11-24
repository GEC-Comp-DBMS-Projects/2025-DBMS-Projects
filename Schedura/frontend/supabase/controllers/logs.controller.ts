
// get logs for a space

import { UserProfile } from "@/types/database.type";
import { supabase } from "../supabase";

export const getLogsForSpace = async (space_id: string) => {
    const { data, error } = await supabase
        .from("access_logs")
        .select("*, users(*)")
        .eq("spaceid", space_id)
        .order("created_at", { ascending: false });
    if (error) {
        console.log("Error Fetching Access Logs for space: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile; space: { name: string } })[] | null,
        error
    };
}
