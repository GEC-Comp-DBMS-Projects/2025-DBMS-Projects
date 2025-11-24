import { supabase } from "../supabase"

export const updateUserInfo = async (user:any) => {
    console.log("UPDATING USERS")
    if (user) {
        const { id, primaryEmailAddress, fullName } = user
        try {
            const data = await supabase.from("users").insert({
                id,
                email:primaryEmailAddress.emailAddress,
                name:fullName,
            })
            return data.status
        }
        catch(error){
            console.log(error);
        }
    }
}

export const getUserInfo = async (userId: string) => {
    console.log("GETTING USER")
    if(!userId){
        console.error("USER ID PROVIDED IS UNDEFINED");
        return;
    }
    try {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();
        return data;
    }
    catch(error){
        console.log(error);
    }
}

export const updateUserUpiId = async (user:any) => {
    if (user) {
        const { id, upiId } = user
        try {
            const data = await supabase.from("users").update({
                upiId
            }).eq('id', id)
            return data.status
        }
        catch(error){
            console.log(error);
        }
    }
}

export const getUserUpiId = async(userId:any) => {
    if(userId){
        try{
            const { data, error: userErr } = await supabase
            .from('users')
            .select('upiId')
            .eq('id', userId)
            .single();
            if(data){
                return data.upiId
            }
        }
        catch(error){
            console.log(error);
        }
    }
}


export const updateUserPushToken = async (userId:string, pushToken:string) => {
    if (userId) {
        try {
            const data = await supabase.from("users").update({
                pushToken
            }).eq('id', userId)
            return data.status
        }
        catch(error){
            console.log(error);
        }
    }
}
export const getUserPushToken = async(userId:any) => {
    if(userId){
        try{
            const { data, error: userErr } = await supabase
            .from('users')
            .select('pushToken')
            .eq('id', userId)
            .single();
            if(data){
                return data.pushToken
            }
        }
        catch(error){
            console.log(error);
        }
    }
}