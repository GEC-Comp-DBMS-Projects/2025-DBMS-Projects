import type { Space } from "@/types/database.type";
import { supabase } from "../supabase"

export async function createSpace(spaceData:Space, files: {filePath:string, fileData:string, fileType:string}[]) {
  const { data, error } = await supabase
    .from("spaces")
    .insert([
      {
        name: spaceData.name,
        capacity: spaceData.capacity,
        location: spaceData.location,
        latitude: spaceData.latitude,
        longitude: spaceData.longitude,
        description: spaceData.description,
        pph: spaceData.pph,
        ownerid: spaceData.ownerid,
        organizationid: spaceData.organizationid,
        category: spaceData.category || 'Social',
      }
    ])
    .select();
  const spaceId = data ? data[0].id! : null;

  const amenities = spaceData?.amenities?.map(name => ({spaceid: spaceId, amenity:name}));  
  const {  error:amenitiesError } = await supabase
    .from("spaces_amenities")
    .insert(amenities || [])
    .select();

  if (amenitiesError) {
    console.error("Error inserting amenities:", amenitiesError);
    return { data: null, error: amenitiesError };
  }
  const uploadResults = await Promise.all(
    files.map(async (file) => {
      const uploadedFileLink = await uploadFile({...file, table: "spaces"});

      await supabase
        .from("spaces-images")
        .insert([
          {
            spaceid:spaceId,
            link: uploadedFileLink
          }
        ])
        .select();
    })
  )
  
  if(uploadResults.some(result => result === null)) {
    console.error("Error uploading one or more images");
    return { data: null, error: new Error("Error uploading one or more images") };
  } 
  return {data, error};
}

export async function deleteMySpace(spaceId: string, userId: string) {
  try {
    const { data: spaceData, error: spaceError } = await supabase
      .from("spaces")
      .select("ownerid")
      .eq("id", spaceId)
      .single();

    if (spaceError || !spaceData) {
      return { data: null, error: new Error("Space not found") };
    }

    if (spaceData.ownerid !== userId) {
      return { data: null, error: new Error("Unauthorized: You can only delete your own spaces") };
    }
    const { data: imagesData, error: imagesError } = await supabase
      .from("spaces-images")
      .select("link")
      .eq("spaceid", spaceId);

    if (imagesError) {
      console.error("Error fetching images:", imagesError);
      return { data: null, error: imagesError };
    }

    if (imagesData && imagesData.length > 0) {
      const filePaths = imagesData.map((image) => image.link.split("/").pop() || "");
      const { error: storageError } = await supabase.storage
        .from("spaces")
        .remove(filePaths);

      if (storageError) {
        console.error("Error deleting files from storage:", storageError);
        return { data: null, error: storageError };
      }
    }

    const { error: imagesDeleteError } = await supabase
      .from("spaces-images")
      .delete()
      .eq("spaceid", spaceId);

    if (imagesDeleteError) {
      console.error("Error deleting image records:", imagesDeleteError);
      return { data: null, error: imagesDeleteError };
    }

    const { data, error: deleteError } = await supabase
      .from("spaces")
      .delete()
      .eq("id", spaceId)
      .select();

    if (deleteError) {
      console.error("Error deleting space:", deleteError);
      return { data: null, error: deleteError };
    }

    return { data: { message: "Space deleted successfully" }, error: null };
  } catch (error) {
    console.error("Unexpected error:", error);
    return { data: null, error: error instanceof Error ? error : new Error("Unknown error occurred") };
  }
}

export async function updateSpace(spaceId: string, userId: string, filePath: string , fileData: string , fileType:string ,spaceData: Partial<Space>) {
  try {
    const { data: spaceCheck, error: checkError } = await supabase
      .from("spaces")
      .select("ownerid")
      .eq("id", spaceId)
      .single();

    if (checkError || !spaceCheck) {
      return { data: null, error: new Error("Space not found") };
    }

    if (spaceCheck.ownerid !== userId) {
      return { data: null, error: new Error("Unauthorized: You can only edit your own spaces") };
    }

    const { data, error } = await supabase
      .from("spaces")
      .update({
        name: spaceData.name,
        location: spaceData.location,
        latitude: spaceData.latitude,
        longitude: spaceData.longitude,
        capacity: spaceData.capacity,
        description: spaceData.description,
        pph: spaceData.pph,
        updated_at: new Date().toISOString(),
      })
      .eq("id", spaceId)
      .select();

    const fileurl = await uploadFile({filePath, fileData, fileType, table: "spaces"});
    console.log("Uploaded file URL:", fileurl);

    const {data : image_data , error: image_error} = await supabase.from("spaces-images").upsert({spaceid:spaceId, link:fileurl});

    if (image_error) {
      console.error("Error updating space image:", image_error);
      return { data: null, error: image_error };
    }

    return { data: data && data.length > 0 ? data[0] : null, error: null };
  } catch (error) {
    console.error("Unexpected error:", error);
    return { data: null, error: error instanceof Error ? error : new Error("Unknown error occurred") };
  }
}

export const uploadFile = async({filePath, fileData, fileType, table}:{filePath:string, fileData:string, fileType:string, table: "spaces" | "organisations"}) => {
  const { data, error } = await supabase
  .storage
  .from(table)
  .upload(filePath, fileData, {
      contentType: fileType || "application/octet-stream"
  });

  if (error) {
    console.error("Upload error:", error);
    return null;
  }

  console.log("File uploaded:", data);

  const { data: publicUrlData } = supabase.storage
  .from(table)
  .getPublicUrl(filePath);

  console.log("Public URL:", publicUrlData.publicUrl);

  return publicUrlData.publicUrl;
}

export const getImagefromId = async (spaceId:string)=>
{
    const {data, error} = await supabase.from("spaces_images").select("link").eq("spaceid", spaceId);
  
    if(error){console.log("Link fetch error: ",error?.message)}
    return {data, error};
} 

export const getSpaceFromId = async (spaceId:string)=>
{
    const {data, error} = await supabase.from("spaces").select("*").eq("id",spaceId).single();
    const spaceImage = await getImagefromId(spaceId);

    return {data, error, spaceImage};
}

export const getSpaces = async () => {
  const { data, error } = await supabase
    .from('spaces')
    .select('*, spaces-images(link)')
  return { data, error };
}

export const getMySpaces = async (userId:string) => {
  const { data, error } = await supabase
    .from('spaces')
    .select('*, spaces-images(link)')
    .eq('ownerid', userId)
    .is('organizationid', null);
    return { data, error };
}

export const getSpaceById = async (spaceId: string) => {
  const { data, error } = await supabase
    .from('spaces')
    .select('*, spaces-images(link), spaces_amenities(*)')
    .eq('id', spaceId)
    .single();
    type SpaceWithImages = Space & { 'spaces-images'?: { link: string }[]; images?: string[] };
    
    let spaceData = data as SpaceWithImages & {'spaces_amenities'?: { amenity: string }[]} | null;
    if (spaceData && Array.isArray(spaceData['spaces-images'])) {
      spaceData.images = spaceData['spaces-images'].map((img) => img.link);
    }
    if (spaceData && Array.isArray(spaceData['spaces_amenities'])) {
      spaceData.amenities = spaceData['spaces_amenities'].map((amenity) => amenity.amenity);
    }
  return { data: spaceData, error };
}
