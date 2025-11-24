import { collection, doc, getDocs, query, where } from "firebase/firestore";
import { auth, db, firebaseApp } from "../firebase";

  // Import the required Firebase dependencies
  import { initializeApp } from 'firebase/app';
  import { 
    getFirestore, 
    // collection, 
    addDoc,
    writeBatch,
    // doc,
    // query,
    // getDocs,
    deleteDoc 
  } from 'firebase/firestore';

import AsyncStorage from '@react-native-async-storage/async-storage';

export const fetchDoc =async () =>{
  const usersCollection = collection(db, "users"); // Reference to the users collection
  const q = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email

  try {
    const querySnapshot = await getDocs(q); // Execute the query

    if (querySnapshot.empty) {
      console.log('No user found with this email:', auth.currentUser?.email);
      return;
    }

    // Assuming emails are unique, get the first document
    const userDoc = querySnapshot.docs[0];

    console.log('User found:', userDoc.data());
    const jsonValue = JSON.stringify(userDoc.data());
    await AsyncStorage.setItem('user', jsonValue);
    return userDoc.data();
    
    
  } catch (error) {
    console.error('Error updating user data:', error);
  }
   
  }






// Initialize Firebase


// Places data
// const placesData = {
//   "places": [
//     {
//       "place_name": "udupi sri krishna temple",
//       "terrain": "urban",
//       "activities": ["temple visits", "cultural rituals", "festivals"],
//       "attractions": ["udupi sri krishna temple", "car street"],
//       "food": ["udupi saaru", "masala dosa", "goli bajje"],
//       "vibe": "spiritual, peaceful",
//       "religion": ["hinduism"],
//       "cultural_heritage": "vaishnavite temple culture",
//       "climate": "tropical",
//       "best_time_to_visit": "october to march",
//       "coordinates": {
//         "latitude": 13.3409,
//         "longitude": 74.7421
//       }
//     },
//     {
//       "place_name": "malpe beach",
//       "terrain": "coastal",
//       "activities": ["water sports", "beach volleyball", "sunset viewing"],
//       "attractions": ["st. mary's island", "sea walk", "fishing harbor"],
//       "food": ["seafood", "malpe fish curry", "neer dosa"],
//       "vibe": "relaxed, adventurous",
//       "religion": ["hinduism", "christianity"],
//       "cultural_heritage": "fishing community, coastal traditions",
//       "climate": "tropical",
//       "best_time_to_visit": "november to february",
//       "coordinates": {
//         "latitude": 13.3495,
//         "longitude": 74.7037
//       }
//     },
//     {
//       "place_name": "kaup beach",
//       "terrain": "coastal",
//       "activities": ["lighthouse visit", "swimming", "photography"],
//       "attractions": ["kaup lighthouse", "kaup beach"],
//       "food": ["bajji", "bonda", "fresh seafood"],
//       "vibe": "serene, scenic",
//       "religion": ["hinduism", "islam"],
//       "cultural_heritage": "traditional coastal town",
//       "climate": "tropical",
//       "best_time_to_visit": "november to march",
//       "coordinates": {
//         "latitude": 13.2134,
//         "longitude": 74.7484
//       }
//     },
//     {
//       "place_name": "manipal",
//       "terrain": "hilly",
//       "activities": ["educational tours", "campus exploration", "nightlife"],
//       "attractions": ["end point", "manipal museum of anatomy and pathology", "hasta shilpa heritage village"],
//       "food": ["local udupi cuisine", "global cuisines"],
//       "vibe": "youthful, academic",
//       "religion": ["hinduism", "christianity", "islam"],
//       "cultural_heritage": "modern educational hub",
//       "climate": "tropical",
//       "best_time_to_visit": "october to march",
//       "coordinates": {
//         "latitude": 13.3525,
//         "longitude": 74.7914
//       }
//     },
//     {
//       "place_name": "st. mary's island",
//       "terrain": "islet",
//       "activities": ["boating", "island exploration", "photography"],
//       "attractions": ["rock formations", "pristine beaches"],
//       "food": ["packed food (no vendors on island)"],
//       "vibe": "remote, tranquil",
//       "religion": ["none"],
//       "cultural_heritage": "geological significance",
//       "climate": "tropical",
//       "best_time_to_visit": "october to february",
//       "coordinates": {
//         "latitude": 13.3747,
//         "longitude": 74.6730
//       }
//     },
//     {
//       "place_name": "manipal end point",
//       "terrain": "hilly",
//       "activities": ["hiking", "jogging", "sightseeing"],
//       "attractions": ["scenic view of udupi", "swarn river"],
//       "food": ["street food nearby", "cafe snacks"],
//       "vibe": "adventurous, calm",
//       "religion": ["none"],
//       "cultural_heritage": "popular student hangout spot",
//       "climate": "tropical",
//       "best_time_to_visit": "evenings throughout the year",
//       "coordinates": {
//         "latitude": 13.3548,
//         "longitude": 74.7841
//       }
//     },
//     {
//       "place_name": "barkur",
//       "terrain": "rural, plains",
//       "activities": ["temple visits", "historical exploration"],
//       "attractions": ["barkur temples", "fort ruins", "heritage sites"],
//       "food": ["local vegetarian fare", "rice-based dishes"],
//       "vibe": "historical, serene",
//       "religion": ["hinduism", "christianity"],
//       "cultural_heritage": "ancient capital of alupa dynasty",
//       "climate": "tropical",
//       "best_time_to_visit": "november to march",
//       "coordinates": {
//         "latitude": 13.4753,
//         "longitude": 74.7043
//       }
//     },
//     {
//       "place_name": "kodi beach",
//       "terrain": "coastal",
//       "activities": ["fishing", "beach walks", "swimming"],
//       "attractions": ["serene beach stretches", "fishing community"],
//       "food": ["fresh seafood", "local snacks"],
//       "vibe": "quiet, relaxing",
//       "religion": ["hinduism", "christianity"],
//       "cultural_heritage": "fishing community culture",
//       "climate": "tropical",
//       "best_time_to_visit": "november to february",
//       "coordinates": {
//         "latitude": 13.6424,
//         "longitude": 74.6795
//       }
//     },
//     {
//       "place_name": "anegudde vinayaka temple",
//       "terrain": "hilly",
//       "activities": ["pilgrimage", "temple visit"],
//       "attractions": ["anegudde vinayaka temple", "festivals"],
//       "food": ["prasadam", "local udupi cuisine"],
//       "vibe": "spiritual, sacred",
//       "religion": ["hinduism"],
//       "cultural_heritage": "ancient temple with local significance",
//       "climate": "tropical",
//       "best_time_to_visit": "year-round, especially during ganesh chaturthi",
//       "coordinates": {
//         "latitude": 13.5275,
//         "longitude": 74.7239
//       }
//     },
//     {
//       "place_name": "delta beach (kodi bengare)",
//       "terrain": "coastal",
//       "activities": ["sunset viewing", "fishing", "river meeting ocean exploration"],
//       "attractions": ["delta point where river meets the sea", "quiet beach"],
//       "food": ["local snacks"],
//       "vibe": "quiet, remote",
//       "religion": ["hinduism", "christianity"],
//       "cultural_heritage": "traditional coastal life",
//       "climate": "tropical",
//       "best_time_to_visit": "november to march",
//       "coordinates": {
//         "latitude": 13.3724,
//         "longitude": 74.6737
//       }
//     }
//   ]
// }


const placesData ={
  "places": [
    {
      "place_name": "baga beach",
      "terrain": "coastal",
      "activities": ["water sports", "beach volleyball", "sunset viewing", "swimming", "photography", "nightlife", "beach walks"],
      "attractions": ["bustling shacks", "water sports stalls", "tropical sunset", "night clubs on sand"],
      "food": ["seafood platters", "goan fish curry", "bebinca dessert"],
      "vibe": "vibrant, party-friendly",
      "religion": ["none"],
      "cultural_heritage": "modern coastal leisure culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.5557, "longitude": 73.7519}
    },
    {
      "place_name": "basilica of bom jesus",
      "terrain": "urban",
      "activities": ["historical exploration", "pilgrimage", "photography", "architectural study"],
      "attractions": ["relic of St. Francis Xavier", "baroque facade", "cathedral interior", "church museum"],
      "food": ["church canteen snacks", "local sweets"],
      "vibe": "spiritual, reflective",
      "religion": ["christianity"],
      "cultural_heritage": "portuguese colonial church heritage",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to february",
      "coordinates": {"latitude": 15.5009, "longitude": 73.9115}
    },
    {
      "place_name": "calangute beach",
      "terrain": "coastal",
      "activities": ["water sports", "beach volleyball", "sunset viewing", "swimming", "photography", "beach walks"],
      "attractions": ["sandcastle vendors", "beach shacks", "raft rides"],
      "food": ["chicken xacuti", "prawn gassi", "fresh fruit shakes"],
      "vibe": "lively, family-friendly",
      "religion": ["none"],
      "cultural_heritage": "beach tourism culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to february",
      "coordinates": {"latitude": 15.5437, "longitude": 73.7554}
    },
    {
      "place_name": "aguada fort",
      "terrain": "coastal",
      "activities": ["historical exploration", "lighthouse visit", "photography", "sightseeing", "educational tours"],
      "attractions": ["17th‑c portuguese walls", "light house", "sea view from ramparts"],
      "food": ["snacks at canteen", "beachside seafood"],
      "vibe": "historic, scenic",
      "religion": ["none"],
      "cultural_heritage": "portuguese military architecture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.4942, "longitude": 73.7737}
    },
    {
      "place_name": "anjuna beach",
      "terrain": "coastal",
      "activities": ["water sports", "sunset viewing", "photography", "nightlife", "beach walks", "flea market browsing"],
      "attractions": ["hippie flea market", "cliffside vistas", "trance parties"],
      "food": ["pasta at shacks", "goan sausages", "coconut water"],
      "vibe": "bohemian, free-spirited",
      "religion": ["none"],
      "cultural_heritage": "counter‑culture hippie legacy",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to february",
      "coordinates": {"latitude": 15.5735, "longitude": 73.7404}
    },
    {
      "place_name": "shri mangueshi temple",
      "terrain": "rural plains",
      "activities": ["temple visits", "cultural rituals", "festivals", "pilgrimage", "photography"],
      "attractions": ["shiva temple complex", "lotus pond", "meditation hall"],
      "food": ["veg thali", "prasad", "temple sweets"],
      "vibe": "serene, devotional",
      "religion": ["hinduism"],
      "cultural_heritage": "goan temple architecture, mangi deity worship",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to february",
      "coordinates": {"latitude": 15.4167, "longitude": 74.0167}
    },
    {
      "place_name": "panaji city",
      "terrain": "urban",
      "activities": ["historical exploration", "photography", "sightseeing", "educational tours"],
      "attractions": ["fontainhas latin quarter", "riverfront promenade", "churches", "markets"],
      "food": ["bebinca", "sorpotel", "rice vindaloo", "cafés"],
      "vibe": ["colonial-chic, relaxed"],
      "religion": ["christianity", "hinduism"],
      "cultural_heritage": "portuguese colonial urban heritage",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.4968, "longitude": 73.8278}
    },
    {
      "place_name": "dudhsagar falls",
      "terrain": "hilly",
      "activities": ["hiking", "photography", "sightseeing"],
      "attractions": ["four-tiered waterfall", "forest trek route", "railway bridge vantage"],
      "food": ["packed meals", "forest-side snacks"],
      "vibe": "adventurous, refreshing",
      "religion": ["none"],
      "cultural_heritage": "western ghats natural heritage",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to february",
      "coordinates": {"latitude": 15.3144, "longitude": 74.3144}
    },
    {
      "place_name": "colva beach",
      "terrain": "coastal",
      "activities": ["sunset viewing", "swimming", "photography", "beach walks", "fishing"],
      "attractions": ["soft white sand", "peaceful shoreline", "fishing boats"],
      "food": ["fish fry", "rice xacuti", "cashew feni"],
      "vibe": "laid-back, family-friendly",
      "religion": ["none"],
      "cultural_heritage": "south goa fishing village atmosphere",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.2797, "longitude": 73.9111}
    },
    {
      "place_name": "se cathedral",
      "terrain": "urban",
      "activities": ["historical exploration", "pilgrimage", "photography", "educational tours"],
      "attractions": ["gothic church hall", "ornate altars", "tower bells"],
      "food": ["church canteen fare", "goan bakery treats"],
      "vibe": "solemn, grand",
      "religion": ["christianity"],
      "cultural_heritage": "portuguese religious architecture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to february",
      "coordinates": {"latitude": 15.5009, "longitude": 73.9115}
    },
    {
      "place_name": "chapora fort",
      "terrain": "coastal",
      "activities": ["historical exploration", "photography", "sightseeing", "sunset viewing"],
      "attractions": ["film‑famous fort ruins", "panoramic hilltop views", "river mouth views"],
      "food": ["street-side snacks", "tea and pakoras"],
      "vibe": "adventurous, cinematic",
      "religion": ["none"],
      "cultural_heritage": "portuguese military past and bollywood fame",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.6026, "longitude": 73.7373}
    },
    {
      "place_name": "candolim beach",
      "terrain": "coastal",
      "activities": ["water sports", "swimming", "sunset viewing", "photography", "beach walks"],
      "attractions": ["quiet stretches", "shacks", "snorkeling spots"],
      "food": ["beachside grills", "goan sausage sandwiches"],
      "vibe": "laid-back, relaxed",
      "religion": ["none"],
      "cultural_heritage": "coastal tourism culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.5176, "longitude": 73.7607}
    },
    {
      "place_name": "shri shantadurga temple",
      "terrain": "rural plains",
      "activities": ["temple visits", "cultural rituals", "festivals", "pilgrimage", "photography"],
      "attractions": ["white temple structure", "festi hall", "devotional music"],
      "food": ["vegetarian prasad", "coconut sweets"],
      "vibe": "peaceful, devout",
      "religion": ["hinduism"],
      "cultural_heritage": "goan temple ritual traditions",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to february",
      "coordinates": {"latitude": 15.3167, "longitude": 74.0167}
    },
    {
      "place_name": "mandrem beach",
      "terrain": "coastal",
      "activities": ["sunset viewing", "swimming", "photography", "beach walks", "jogging"],
      "attractions": ["calm shores", "casuarina-lined dunes"],
      "food": ["shack-style vegetarian meals", "fresh coconut water"],
      "vibe": "tranquil, rejuvenating",
      "religion": ["none"],
      "cultural_heritage": "quiet north goa coastal way of life",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.6476, "longitude": 73.7276}
    },
    {
      "place_name": "reis magos fort",
      "terrain": "coastal",
      "activities": ["historical exploration", "photography", "sightseeing", "educational tours"],
      "attractions": ["16th‑c fort structure", "museum exhibits", "river views"],
      "food": ["canteen snacks", "fort-view café"],
      "vibe": "cultural, evocative",
      "religion": ["none"],
      "cultural_heritage": "portuguese colonial fort heritage",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.5033, "longitude": 73.8244}
    },
    {
      "place_name": "arambol beach",
      "terrain": "coastal",
      "activities": ["sunset viewing", "swimming", "photography", "nightlife", "beach walks"],
      "attractions": ["freshwater lake", "community music circles", "sunset hills"],
      "food": ["vegan café fare", "goan seafood"],
      "vibe": "hippie, communal",
      "religion": ["none"],
      "cultural_heritage": "alternative community seaside culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.6869, "longitude": 73.7026}
    },
    {
      "place_name": "cabo de rama beach",
      "terrain": "coastal",
      "activities": ["sunset viewing", "photography", "beach walks", "historical exploration", "fishing"],
      "attractions": ["fort ruins", "rocky shoreline", "quiet cove"],
      "food": ["fishermen’s catch", "beach snacks"],
      "vibe": "secluded, rustic",
      "religion": ["none"],
      "cultural_heritage": "portuguese fort-offshore life",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.0903, "longitude": 73.9167}
    },
    {
      "place_name": "divar island",
      "terrain": "islet",
      "activities": ["island exploration", "photography", "sightseeing", "historical exploration"],
      "attractions": ["ancient churches", "village lanes", "ferry crossings"],
      "food": ["home‑cooked goan fare", "river fish curry"],
      "vibe": "nostalgic, peaceful",
      "religion": ["christianity", "hinduism"],
      "cultural_heritage": "village agrarian and religious island life",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.5167, "longitude": 73.9167}
    },
    {
      "place_name": "vasco da gama",
      "terrain": "urban",
      "activities": ["historical exploration", "photography", "sightseeing", "educational tours"],
      "attractions": ["port area", "naval museum", "old railway station"],
      "food": ["local fish thali", "street snacks"],
      "vibe": "industrial, authentic",
      "religion": ["hinduism", "christianity", "islam"],
      "cultural_heritage": "goa’s maritime and trading heritage",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.3958, "longitude": 73.8158}
    },
    {
      "place_name": "morjim beach",
      "terrain": "coastal",
      "activities": ["sunset viewing", "swimming", "photography", "beach walks", "wildlife observation"],
      "attractions": ["olive ridley turtle nesting grounds", "vast dunes"],
      "food": ["russian bakeries", "seafood", "vegetarian shacks"],
      "vibe": "turtle‑friendly, chilled",
      "religion": ["none"],
      "cultural_heritage": "eco‑conscious beach tourism",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to january",
      "coordinates": {"latitude": 15.6250, "longitude": 73.7281}
    },
    {
      "place_name": "betim ferry point",
      "terrain": "coastal",
      "activities": ["boating", "photography", "sightseeing", "river meeting ocean exploration"],
      "attractions": ["mandovi river ferry", "riverfront panorama"],
      "food": ["river‑side snacks", "tea stall"],
      "vibe": "traditional, scenic",
      "religion": ["none"],
      "cultural_heritage": "goan ferry-trade river culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.4833, "longitude": 73.8333}
    },
    {
      "place_name": "butterfly beach",
      "terrain": "coastal",
      "activities": ["hiking", "swimming", "photography", "beach walks", "wildlife observation"],
      "attractions": ["secluded cove", "butterfly spotting"],
      "food": ["packed snacks", "no vendors"],
      "vibe": "secretive, natural",
      "religion": ["none"],
      "cultural_heritage": "untouched coastal ecology",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.0167, "longitude": 73.9667}
    },
    {
      "place_name": "chorao island",
      "terrain": "islet",
      "activities": ["island exploration", "photography", "wildlife observation", "boating", "educational tours"],
      "attractions": ["salim ali bird sanctuary", "mangrove trails", "village life"],
      "food": ["homemade goan meals", "river fish curry"],
      "vibe": "eco‑friendly, tranquil",
      "religion": ["hinduism", "islam", "christianity"],
      "cultural_heritage": "biodiversity conservation & rural lifestyle",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to february",
      "coordinates": {"latitude": 15.5167, "longitude": 73.95}
    },
    {
      "place_name": "fontainhas latin quarter",
      "terrain": "urban",
      "activities": ["historical exploration", "photography", "sightseeing", "educational tours"],
      "attractions": ["colorful colonial houses", "art galleries", "cafés"],
      "food": ["portuguese pastries", "espresso", "light meals"],
      "vibe": "artsy, charming",
      "religion": ["none"],
      "cultural_heritage": "portuguese goan colonial quarter",
      "climate": "tropical monsoon",
      "best_time_to_visit": "october to march",
      "coordinates": {"latitude": 15.4950, "longitude": 73.8267}
    },
    {
      "place_name": "sinquerim beach",
      "terrain": "coastal",
      "activities": ["water sports", "swimming", "sunset viewing", "photography", "beach walks"],
      "attractions": ["clear water cove", "nearby aguada fort", "beach shacks"],
      "food": ["grilled seafood", "cashew drinks"],
      "vibe": "peaceful, active",
      "religion": ["none"],
      "cultural_heritage": "coastal leisure culture",
      "climate": "tropical monsoon",
      "best_time_to_visit": "november to march",
      "coordinates": {"latitude": 15.4950, "longitude": 73.7731}
    }
  ]
}

  

// Function to import places data to Firestore
export const importPlacesToFirestore = async () => {
  try {
    // Create a batch
    const batch = writeBatch(db);
    const placesRef = collection(db, 'places');

    // First, delete existing documents
    console.log('Clearing existing places...');
    const existingDocs = await getDocs(query(placesRef));
    existingDocs.forEach(doc => {
      batch.delete(doc.ref);
    });

    // Add new documents
    console.log('Adding new places...');
    placesData.places.forEach((place) => {
      const docRef = doc(placesRef); // Firestore will generate an ID
      batch.set(docRef, {
        ...place,
        // Add timestamps
        created_at: new Date(),
        updated_at: new Date(),
        // Add a searchable lowercase version of the place name
        search_name: place.place_name.toLowerCase(),
        // Add a GeoPoint for the coordinates
        location: {
          latitude: place.coordinates.latitude,
          longitude: place.coordinates.longitude
        }
      });
    });

    // Commit the batch
    await batch.commit();
    console.log('Successfully imported all places to Firestore');

  } catch (error) {
    console.error('Error importing places:', error);
    throw error;
  }
};




const questsData ={
  "quests": [
    {
      "quest": "Experience Goa’s Beaches",
      "description": "Relax and soak up the sun at popular Goa beaches like Baga, Calangute and Anjuna. Try water sports, beach walks, nightlife, and beachside dining.",
      "activities": ["water sports", "beach walks", "sunset viewing", "nightlife"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.5557, "longitude": 73.7519 },
      "user_id_completed": null
    },
    {
      "quest": "Visit Basilica of Bom Jesus",
      "description": "Explore this UNESCO World Heritage Site housing the relics of St. Francis Xavier. Admire its baroque architecture and serene cathedral interior.",
      "activities": ["historical exploration", "pilgrimage", "photography"],
      "terrain": "urban",
      "coordinates": { "latitude": 15.5009, "longitude": 73.9115 },
      "user_id_completed": null
    },
    {
      "quest": "Explore Aguada Fort and Lighthouse",
      "description": "Walk around the 17th‑century Portuguese fortress, explore its ramparts and lighthouse, and enjoy panoramic views over the Arabian Sea.",
      "activities": ["historical exploration", "lighthouse visit", "photography"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.4942, "longitude": 73.7737 },
      "user_id_completed": null
    },
    {
      "quest": "Experience the Chapora Fort Sunset",
      "description": "Climb Chapora Fort (made famous in Bollywood) and catch a stunning sunset view over the river mouth and sea.",
      "activities": ["sightseeing", "photography", "sunset viewing"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.6026, "longitude": 73.7373 },
      "user_id_completed": null
    },
    {
      "quest": "Stroll Through Panaji’s Fontainhas",
      "description": "Wander the colorful lanes of Panaji’s Portuguese Latin Quarter, with its colonial houses, cafes, and boutique shops.",
      "activities": ["historical exploration", "sightseeing", "photography"],
      "terrain": "urban",
      "coordinates": { "latitude": 15.4950, "longitude": 73.8267 },
      "user_id_completed": null
    },
    {
      "quest": "Attend a Goan Feni Tasting",
      "description": "Sample Goa's iconic cashew or coconut feni at a local distillery or beach shack.",
      "activities": ["culinary exploration", "nightlife"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.5437, "longitude": 73.7554 },
      "user_id_completed": null
    },
    {
      "quest": "Explore Dudhsagar Falls",
      "description": "Trek through lush Western Ghats forests to witness the majestic Dudhsagar Falls, one of India’s tallest cascades.",
      "activities": ["hiking", "photography", "sightseeing"],
      "terrain": "hilly",
      "coordinates": { "latitude": 15.3144, "longitude": 74.3144 },
      "user_id_completed": null
    },
    {
      "quest": "Discover Shri Mangueshi Temple",
      "description": "Visit one of Goa’s most revered Shiva temples known for its Indo-Portuguese architecture and serene surroundings.",
      "activities": ["temple visits", "cultural rituals", "pilgrimage"],
      "terrain": "rural plains",
      "coordinates": { "latitude": 15.4167, "longitude": 74.0167 },
      "user_id_completed": null
    },
    {
      "quest": "Sunset at Mandrem Beach",
      "description": "Find tranquility at Mandrem Beach with quiet sands, gentle waves, and a stunning sunset in North Goa.",
      "activities": ["sunset viewing", "beach walks", "swimming"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.6476, "longitude": 73.7276 },
      "user_id_completed": null
    },
    {
      "quest": "Go Island Hopping to Chorao & Divar",
      "description": "Take ferries to Chorao (Salim Ali Bird Sanctuary) and Divar Island (ancient churches and village life) for a rustic getaway.",
      "activities": ["boating", "wildlife observation", "photography"],
      "terrain": "islet",
      "coordinates": { "latitude": 15.5167, "longitude": 73.95 },
      "user_id_completed": null
    },
    {
      "quest": "Explore Cabo de Rama Beach & Fort",
      "description": "Discover the quiet, secluded Cabo de Rama with its historical fort ruins and scenic shoreline.",
      "activities": ["historical exploration", "beach walks", "photography"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.0903, "longitude": 73.9167 },
      "user_id_completed": null
    },
    {
      "quest": "Shop at Anjuna Flea Market",
      "description": "Browse stalls offering bohemian clothes, jewelry, crafts and local art at the famous Anjuna Flea Market.",
      "activities": ["shopping", "sightseeing"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.5735, "longitude": 73.7404 },
      "user_id_completed": null
    },
    {
      "quest": "Taste Authentic Goan Cuisine",
      "description": "Savor local Goan dishes like Xacuti, Sorpotel, Vindaloo and Bebinca at traditional beach shacks or heritage restaurants.",
      "activities": ["culinary exploration"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.5176, "longitude": 73.7607 },
      "user_id_completed": null
    },
    {
      "quest": "Photograph Butterfly Beach",
      "description": "Take a boat or hike to hidden Butterfly Beach and catch its pristine beauty with butterflies and secluded coves.",
      "activities": ["hiking", "photography", "swimming"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.0167, "longitude": 73.9667 },
      "user_id_completed": null
    },
    {
      "quest": "Visit Reis Magos Fort",
      "description": "Explore this beautifully restored 16th‑century fort with museum exhibits and stunning river/sea views.",
      "activities": ["historical exploration", "sightseeing", "photography"],
      "terrain": "coastal",
      "coordinates": { "latitude": 15.5033, "longitude": 73.8244 },
      "user_id_completed": null
    }
  ]
}


// Function to add quests to Firestore
export const addQuestsToFirestore = async () => {
  try {
    const questsCollectionRef = collection(db, 'quests'); // Reference to the 'quests' collection

    // Loop through the quests array and add each quest as a document
    for (const quest of questsData.quests) {
      await addDoc(questsCollectionRef, quest);
      console.log(`Quest "${quest.quest}" added successfully.`);
    }
    console.log('All quests have been added successfully!');
  } catch (error) {
    console.error('Error adding quests to Firestore:', error);
  }
};


// Example utility functions for querying the data
const placeQueries = {
  // Get all places
  getAllPlaces: async () => {
    try {
      const placesRef = collection(db, 'places');
      const snapshot = await getDocs(placesRef);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error getting places:', error);
      throw error;
    }
  },

  // Get places by terrain
  getPlacesByTerrain: async (terrain) => {
    try {
      const q = query(
        collection(db, 'places'),
        where('terrain', '==', terrain)
      );
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error getting places by terrain:', error);
      throw error;
    }
  },

  // Get places by activity
  getPlacesByActivity: async (activity) => {
    try {
      const q = query(
        collection(db, 'places'),
        where('activities', 'array-contains', activity)
      );
      const snapshot = await getDocs(q);
      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
    } catch (error) {
      console.error('Error getting places by activity:', error);
      throw error;
    }
  },

  

  // Update a place
  updatePlace: async (placeId, updateData) => {
    try {
      const placeRef = doc(db, 'places', placeId);
      await updateDoc(placeRef, {
        ...updateData,
        updated_at: new Date()
      });
      console.log('Place updated successfully');
    } catch (error) {
      console.error('Error updating place:', error);
      throw error;
    }
  },

  // Delete a place
  deletePlace: async (placeId) => {
    try {
      await deleteDoc(doc(db, 'places', placeId));
      console.log('Place deleted successfully');
    } catch (error) {
      console.error('Error deleting place:', error);
      throw error;
    }
  }
};

// Execute the import
importPlacesToFirestore()
  .then(() => console.log('Import completed successfully'))
  .catch(error => console.error('Import failed:', error));

// Example usage of the queries:
/*
// Get all places
const allPlaces = await placeQueries.getAllPlaces();

// Get coastal places
const coastalPlaces = await placeQueries.getPlacesByTerrain('coastal');

// Get places with temple visits
const templePlaces = await placeQueries.getPlacesByActivity('temple visits');

// Update a place
await placeQueries.updatePlace('placeId', {
  vibe: 'updated vibe',
  food: ['updated', 'food', 'items']
});

// Delete a place
await placeQueries.deletePlace('placeId');
*/