import type { UserProfile } from "@/types/database.type";
import { supabase } from "../supabase"

export const sendBookRequest = async(space_id:string, start_date: string , end_date:string, user_id:string, reason:string)=>{
    const {error} =await supabase.from("requests").insert({spaceid: space_id , start: start_date , end: end_date , approved:false, created_by:user_id, reason:reason});

    if(error){console.log("Error Inserting in Requests table: ",error); throw error;}

    return{success: true}
}

export const getRequestsForSpace = async (space_id: string) => {
    const { data, error } = await supabase
        .from("requests")
        .select("*, users:created_by(*), space:spaceid(name, ownerid)")
        .eq("spaceid", space_id)
        .order("created_at", { ascending: false });
    if (error) {
        console.log("Error Fetching Requests for space: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile; space: { name: string } })[] | null,
        error
    };
}

export const getRequestsOfUser = async (user_id: string) => {
    const { data, error } = await supabase
        .from("requests")
        .select("*, users:created_by(*), space:spaceid(*)")
        .eq("created_by", user_id)
        .order("created_at", { ascending: false });
    if (error) {
        console.log("Error Fetching Requests for user: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile; space: { name: string } })[] | null,
        error
    };
}

export const acceptRequest = async(requestid: string, userid:string) => {
    
    const { data: requestData, error: requestError } = await supabase
        .from("requests")
        .select("*, space:spaceid(name, ownerid)")
        .eq("id", requestid)
        .single();
    console.log("Request Data: ", requestData);
    if (requestError || !requestData) {
        console.log("Error fetching request: ", requestError);
        throw requestError || new Error("Request not found");
    }

    if(requestData.space.ownerid !== userid) {
        console.log("User is not the owner of the space");
        throw new Error("User is not the owner of the space");
    }


    // make sure that day is not booked already
    const { data: existingBookings, error: bookingsError } = await supabase
        .from("bookings")
        .select("*")
        .eq("spaceid", requestData.spaceid)
        .lt("start", requestData.end)   // booking.start < requested.end
        .gt("end", requestData.start);  // booking.end > requested.start


    
    if (bookingsError) {
        console.log("Error checking existing bookings: ", bookingsError);
        throw bookingsError;
    }

    if (existingBookings && existingBookings.length > 0) {
        console.log("The requested time slot is already booked.");
        throw new Error("The requested time slot is already booked.");
    }

    const { data: bookingData, error: bookingError } = await supabase
        .from("bookings")
        .insert({
            spaceid: requestData.spaceid,
            start: requestData.start,
            end: requestData.end,
            userid: requestData.created_by,
        })
        .select()
        .single();
    
    if(bookingError) {
        console.log("Error creating booking: ", bookingError);
        throw bookingError;
    }

    const { error: deleteError } = await supabase
        .from("requests")
        .delete()
        .eq("id", requestid);

    if(deleteError) {
        console.log("Error deleting request: ", deleteError);
        throw deleteError;
    }

    const { error: overlapDeleteError } = await supabase
        .from("requests")
        .delete()
        .eq("spaceid", requestData.spaceid)
        .lt("start", requestData.end)   // request.start < booked.end
        .gt("end", requestData.start);  // request.end > booked.start

    if(overlapDeleteError) {
        console.log("Error deleting overlapping requests: ", overlapDeleteError);
        throw overlapDeleteError;
    }
    
};

export const rejectRequest = async(requestid: string, userid:string) => {
    
    const { error: deleteError } = await supabase
        .from("requests")
        .delete()
        .eq("id", requestid);

    if(deleteError) {
        console.log("Error deleting request: ", deleteError);
        throw deleteError;
    }
    
};
