import AsyncStorage from '@react-native-async-storage/async-storage';

// Removed global attractionDataArray

// Function to fetch tourist attractions using Overpass API
async function fetchTouristAttractions(latitude:any, longitude:any, typeOfPlace:string ,category:string, radius = 40000) {
  const query = `
    [out:json];
    (
      node[${category}=${typeOfPlace}](around:${radius}, ${latitude}, ${longitude});
     
    );
    out body;
  `;

  const response = await fetch('https://overpass-api.de/api/interpreter', {
    method: 'POST',
    body: query,
    headers: { 'Content-Type': 'text/plain' }
  });
  const data = await response.json();
  return data.elements;
}

// Function to calculate road distance using OSRM
async function calculateRoadDistance(startLat:any, startLon:any, endLat:any, endLon:any) {
  const url = `https://router.project-osrm.org/route/v1/driving/${startLon},${startLat};${endLon},${endLat}?overview=false&geometries=polyline&steps=false`;
  const response = await fetch(url);
  const data = await response.json();
  if (data.routes && data.routes.length > 0) {
    const distance = data.routes[0].distance; // Distance in meters
    const duration = data.routes[0].duration; // Duration in seconds
    return { distance, duration };
  } else {
    throw new Error('No route found');
  }
}


export const fetchAttractions = async (latitude: any, longitude: any,typeOfAttraction:string,category:string,radius:number) => {
  let attractionDataArray:any = []; // Initialize inside the function to avoid duplicates

  console.log("lat: ", latitude, "lon: ", longitude);
  try {
    const attractions = await fetchTouristAttractions(latitude, longitude,typeOfAttraction,category,radius);

    console.log("attract: ", attractions)
    const uniqueAttractions = new Set();
   

    for (let attraction of attractions) {
      const attractionId = attraction.id;

      if (!uniqueAttractions.has(attractionId)) {
        uniqueAttractions.add(attractionId);

        if (attraction.lat && attraction.lon) {
          const name = attraction.tags?.name || 'Unnamed';

          const distanceData = await calculateRoadDistance(latitude, longitude, attraction.lat, attraction.lon);
          const distanceKm = (distanceData.distance / 1000).toFixed(2);
          const durationMinutes = Math.round(distanceData.duration / 60);

          attractionDataArray.push({
            name: name,
            lat: attraction.lat,
            lon: attraction.lon,
            distance: distanceKm,
            time: durationMinutes
          });
        }
      }
      if (attractionDataArray.length >= 7) {
        break;
      }
    }

    attractionDataArray.sort((a: any, b: any) => a.distance - b.distance);
    console.log("Sorted: ",attractionDataArray)

    try {
      await AsyncStorage.setItem('closestAttractions', JSON.stringify(attractionDataArray));
      console.log('Closest attractions saved to storage');
    } catch (error) {
      console.error('Error saving closest attractions to storage:', error);
    }

    return attractionDataArray;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};



