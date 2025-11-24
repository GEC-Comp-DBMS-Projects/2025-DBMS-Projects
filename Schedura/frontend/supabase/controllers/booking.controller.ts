import type { UserProfile } from "@/types/database.type";
import { supabase } from "../supabase"

// get bookings for a space
export const getBookingsForSpaceByMonthYear = async (
    space_id: string,
    month: number, // 1-12
    year: number
) => {
    // Construct start and end dates for the month
    const startDate = new Date(year, month-1, 1).toISOString();
    const endDate = new Date(year, month, 1).toISOString();

    const { data, error } = await supabase
        .from("bookings")
        .select("*, users:userid(*)")
        .eq("spaceid", space_id)
        .gte("created_at", startDate)
        .lt("created_at", endDate)
        .order("created_at", { ascending: false });

    if (error) {
        console.log("Error Fetching Bookings for space by month/year: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile })[] | null,
        error
    };
};

export const getBookingsForSpace = async (space_id: string) => {
    const { data, error } = await supabase
        .from("bookings")
        .select("*, users:userid(*), space:spaceid(name)")
        .eq("spaceid", space_id)
        .order("created_at", { ascending: false });

    if (error) {
        console.log("Error Fetching Bookings for space: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile })[] | null,
        error
    };
}

export const getBookingsOfUser = async (user_id: string) => {
    const { data, error } = await supabase
        .from("bookings")
        .select("*, users:userid(*), space:spaceid(*)")
        .eq("userid", user_id)
        .order("created_at", { ascending: false });

    if (error) {
        console.log("Error Fetching Bookings for space: ", error);
        throw error;
    }
    return {
        data: data as (UserProfile & { id: string; users: UserProfile })[] | null,
        error
    };
}

export const acceptBooking = async (booking_id: string) => {
    const { data, error } = await supabase
        .from("bookings")
        .update({ payment_status: "accepted" })
        .eq("id", booking_id)
        .select();

    if (error) {
        console.log("Error Accepting Booking: ", error);
        throw error;
    }
    return {
        data: data as any[] | null,
        error
    };
}