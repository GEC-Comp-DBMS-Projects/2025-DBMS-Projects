import type { Space } from "@/types/database.type";
import { supabase } from "../supabase"


export async function getBookingOfSpace(spaceId: string){ // return all bookings of a space 

    if(!spaceId){
        throw new Error("Space ID is required");
    }

    try{
        const {data , error} = await supabase.from('bookings').select('*').eq('spaceid' , spaceId);

        if(error || !data){
            return {data: null , error: error || new Error("No data Found!!")};
        }

        console.log("typeof data" , typeof data);
        console.log("data" , data); 

        return {data: data as any[] , error: null};

    }catch(error){
        return {data: null , error: error as Error};
    }
}

export async function getTotalBookings(spaceId: string){
    if(!spaceId){
        throw new Error("Space ID is required");
    }

    try{
        const {data , error} = await supabase.from("bookings").select("id" , {count: 'exact'}).eq('spaceid' , spaceId);

        if(error || !data){
            return {data: 0 , error: error || new Error("no data found")};
        }

        return {data: data.length , error: null};
    }catch(error){
        return {data: 0 , error: error as Error};
    }
}

export async function getRequestpending(spaceId: string){
    if(!spaceId){
        throw new Error("Space ID is required");
    }

    try{
        const {data , error} = await supabase.from("requests").select("id" , {count: 'exact'}).eq("spaceid" , spaceId).eq("approved" , false);

        console.log("pending requests data:", data, "error:", error);

        if(error || !data){
            return {data: 0 , error: error || new Error("no data found")};
        } 

        return {data: data.length , error:null};
    }catch(error){
        return {data: 0 , error: error as Error};
    }
}


export async function getBookingbyUserId(userId: string){
    if(!userId){
        throw new Error("User ID is required");
    }

    try{
        const {data , error} = await supabase.from("bookings").select("*").eq("userid" , userId);

        if(error || !data){
            return {data: null , error: error || new Error("no data found")};
        }

        return {data: data as any[] , error: null};
    }
    catch(error){
        return {data: null , error: error as Error};
    }
}