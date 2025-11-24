// Price alerts and scam warnings database for different location types and activities

export interface PriceItem {
  item: string;
  fairPrice: string;
  scamPrice?: string;
  warning?: string;
  icon: string;
}

export interface ScamAlert {
  title: string;
  description: string;
  severity: 'high' | 'medium' | 'low';
  icon: string;
}

export interface LocationPriceData {
  items: PriceItem[];
  scams: ScamAlert[];
  tips: string[];
}

// Price data for different location types
export const priceDatabase: { [key: string]: LocationPriceData } = {
  // Beaches
  beach: {
    items: [
      {
        item: 'Water Sports (Parasailing)',
        fairPrice: '₹500-800',
        scamPrice: '₹1500-2000',
        warning: 'Book directly at beach shacks, avoid touts',
        icon: 'water'
      },
      {
        item: 'Jet Ski (15 min)',
        fairPrice: '₹600-1000',
        scamPrice: '₹1500-2500',
        warning: 'Negotiate price before starting',
        icon: 'speedboat'
      },
      {
        item: 'Beach Umbrella & Chairs',
        fairPrice: '₹100-200',
        scamPrice: '₹500',
        warning: 'Ask for price upfront',
        icon: 'umbrella'
      },
      {
        item: 'Coconut Water',
        fairPrice: '₹30-50',
        scamPrice: '₹100-150',
        warning: 'Tourist price is often 3x normal',
        icon: 'nutrition'
      },
      {
        item: 'Fresh Juice',
        fairPrice: '₹40-80',
        scamPrice: '₹150-200',
        icon: 'cafe'
      },
      {
        item: 'Beach Photography',
        fairPrice: '₹200-500',
        scamPrice: '₹1000+',
        warning: 'Confirm price and number of photos before',
        icon: 'camera'
      }
    ],
    scams: [
      {
        title: 'Water Sports Package Scam',
        description: 'Touts approach with "special package deals" that are overpriced. Always book at official beach shacks.',
        severity: 'high',
        icon: 'warning'
      },
      {
        title: 'Forced Photography',
        description: 'Photographers take photos without asking, then demand high payment. Politely refuse beforehand.',
        severity: 'medium',
        icon: 'camera'
      },
      {
        title: 'Parking Touts',
        description: 'Unofficial people charge inflated parking fees. Look for official parking signs.',
        severity: 'medium',
        icon: 'car'
      },
      {
        title: 'Locker/Storage Scam',
        description: 'Overpriced storage lockers. Keep valuables with you or at hotel.',
        severity: 'low',
        icon: 'lock-closed'
      }
    ],
    tips: [
      'Always negotiate water sports prices before participating',
      'Carry small change to avoid "no change" scams',
      'Check if beach has free/paid entry beforehand',
      'Avoid leaving valuables unattended on beach'
    ]
  },

  // Restaurants & Cafes
  restaurant: {
    items: [
      {
        item: 'Goan Fish Curry Meal',
        fairPrice: '₹250-400',
        scamPrice: '₹600-800',
        icon: 'restaurant'
      },
      {
        item: 'Beer (Kingfisher)',
        fairPrice: '₹80-150',
        scamPrice: '₹250-350',
        warning: 'Tourist areas charge premium',
        icon: 'beer'
      },
      {
        item: 'Fresh Seafood Platter',
        fairPrice: '₹600-1000',
        scamPrice: '₹1500-2000',
        icon: 'fish'
      },
      {
        item: 'Breakfast (Continental)',
        fairPrice: '₹200-350',
        scamPrice: '₹500-700',
        icon: 'cafe'
      },
      {
        item: 'Bottled Water (1L)',
        fairPrice: '₹20-40',
        scamPrice: '₹80-100',
        warning: 'Highly marked up at tourist spots',
        icon: 'water'
      }
    ],
    scams: [
      {
        title: 'Menu Price Switch',
        description: 'Prices on menu differ from bill. Always check menu prices and verify bill.',
        severity: 'high',
        icon: 'receipt'
      },
      {
        title: 'Service Charge Scam',
        description: 'Unauthorized service charges added. Service charge is optional in India.',
        severity: 'medium',
        icon: 'card'
      },
      {
        title: 'Fresh Catch Overpricing',
        description: 'Seafood weighed incorrectly or priced per 100g shown as total. Confirm pricing method.',
        severity: 'high',
        icon: 'scale'
      },
      {
        title: 'Cover Charge',
        description: 'Hidden cover charges per person. Ask about all charges upfront.',
        severity: 'medium',
        icon: 'alert-circle'
      }
    ],
    tips: [
      'Always check the menu prices before ordering',
      'Ask for bill breakdown if charges seem high',
      'Service charge is optional - you can refuse it',
      'Confirm seafood pricing method (per kg, per plate, etc.)'
    ]
  },

  // Heritage Sites & Forts
  heritage: {
    items: [
      {
        item: 'Entry Fee (Indian)',
        fairPrice: '₹25-50',
        scamPrice: 'Free at many forts',
        warning: 'Many forts have free entry',
        icon: 'ticket'
      },
      {
        item: 'Entry Fee (Foreign)',
        fairPrice: '₹100-300',
        scamPrice: '₹500+',
        icon: 'ticket'
      },
      {
        item: 'Guide Services',
        fairPrice: '₹200-500',
        scamPrice: '₹1000-2000',
        warning: 'Negotiate beforehand, avoid touts',
        icon: 'people'
      },
      {
        item: 'Parking',
        fairPrice: '₹20-50',
        scamPrice: '₹100-200',
        warning: 'Use official parking only',
        icon: 'car'
      },
      {
        item: 'Souvenirs',
        fairPrice: '₹50-200',
        scamPrice: '₹500-1000',
        warning: 'Heavily negotiable',
        icon: 'gift'
      }
    ],
    scams: [
      {
        title: 'Fake Guides',
        description: 'Unofficial guides charge high fees and provide incorrect information. Use official guides only.',
        severity: 'high',
        icon: 'person'
      },
      {
        title: 'Photography Fee Scam',
        description: 'Extra charges for camera/phone that don\'t exist. Check official rules.',
        severity: 'medium',
        icon: 'camera'
      },
      {
        title: 'Shoe Storage Scam',
        description: 'Overpriced shoe keeping at religious sites. Carry a bag or use official counters.',
        severity: 'low',
        icon: 'footsteps'
      },
      {
        title: 'Donation Scam',
        description: 'People pose as temple priests requesting donations. Give only if you wish.',
        severity: 'medium',
        icon: 'hand-left'
      }
    ],
    tips: [
      'Hire guides through official heritage site counters',
      'Many monuments are free or have minimal entry fees',
      'Bargain hard for souvenirs - start at 50% quoted price',
      'Carry your own water to avoid inflated prices'
    ]
  },

  // Markets & Shopping
  market: {
    items: [
      {
        item: 'Handicraft Items',
        fairPrice: '₹100-500',
        scamPrice: '₹800-2000',
        warning: 'Start negotiating at 40% of quoted price',
        icon: 'color-palette'
      },
      {
        item: 'Clothing/Beachwear',
        fairPrice: '₹200-600',
        scamPrice: '₹1000-2000',
        warning: 'Heavily negotiable',
        icon: 'shirt'
      },
      {
        item: 'Jewelry (Artificial)',
        fairPrice: '₹150-400',
        scamPrice: '₹800-1500',
        icon: 'diamond'
      },
      {
        item: 'Cashew Nuts (1kg)',
        fairPrice: '₹400-600',
        scamPrice: '₹1000-1500',
        warning: 'Buy from shops with fixed prices',
        icon: 'nutrition'
      },
      {
        item: 'Spices Package',
        fairPrice: '₹200-400',
        scamPrice: '₹800-1200',
        icon: 'leaf'
      }
    ],
    scams: [
      {
        title: 'Fixed Price Lie',
        description: 'Vendors claim "government fixed price" - it\'s negotiable. Bargain aggressively.',
        severity: 'high',
        icon: 'pricetag'
      },
      {
        title: 'Fake Branded Goods',
        description: 'Counterfeit items sold as originals at high prices. Be cautious of too-good deals.',
        severity: 'high',
        icon: 'warning'
      },
      {
        title: 'Weighted Scale Scam',
        description: 'Rigged scales for spices/cashews. Watch the weighing process.',
        severity: 'high',
        icon: 'scale'
      },
      {
        title: 'Gemstone Scam',
        description: 'Fake gemstones sold as authentic. Only buy from certified jewelers.',
        severity: 'high',
        icon: 'diamond'
      }
    ],
    tips: [
      'Always bargain - start at 40-50% of asking price',
      'Walk away if price is too high - seller often calls back',
      'Compare prices at multiple shops before buying',
      'Avoid shops that taxi/guide drivers recommend'
    ]
  },

  // Adventure Activities
  adventure: {
    items: [
      {
        item: 'Trekking Guide',
        fairPrice: '₹500-1000',
        scamPrice: '₹2000-3000',
        icon: 'trail-sign'
      },
      {
        item: 'Kayaking (1hr)',
        fairPrice: '₹500-800',
        scamPrice: '₹1500-2000',
        warning: 'Book through official operators',
        icon: 'boat'
      },
      {
        item: 'Scuba Diving (Beginner)',
        fairPrice: '₹2500-4000',
        scamPrice: '₹6000-8000',
        warning: 'Check certification of operator',
        icon: 'water'
      },
      {
        item: 'Bike Rental (per day)',
        fairPrice: '₹300-600',
        scamPrice: '₹1000-1500',
        warning: 'Check bike condition, take photos',
        icon: 'bicycle'
      },
      {
        item: 'Zip-lining',
        fairPrice: '₹400-800',
        scamPrice: '₹1500-2000',
        icon: 'analytics'
      }
    ],
    scams: [
      {
        title: 'Equipment Damage Scam',
        description: 'Claim pre-existing damage when you return equipment. Take photos/videos before use.',
        severity: 'high',
        icon: 'camera'
      },
      {
        title: 'Unqualified Operators',
        description: 'Adventure sports without proper safety equipment or certification. Verify credentials.',
        severity: 'high',
        icon: 'shield-checkmark'
      },
      {
        title: 'Fuel Tank Scam',
        description: 'Rental vehicles returned with "less fuel". Fill tank and keep receipt.',
        severity: 'medium',
        icon: 'speedometer'
      },
      {
        title: 'Hidden Charges',
        description: 'Additional fees for insurance, helmet, etc. Get full price breakdown upfront.',
        severity: 'medium',
        icon: 'receipt'
      }
    ],
    tips: [
      'Always book adventure activities through certified operators',
      'Take photos/videos of rental equipment before use',
      'Verify safety equipment is provided and in good condition',
      'Keep deposit receipts and get written agreements'
    ]
  },

  // Temples/Churches
  temple: {
    items: [
      {
        item: 'Shoe Storage',
        fairPrice: 'Free or ₹10',
        scamPrice: '₹50-100',
        warning: 'Many temples have free storage',
        icon: 'footsteps'
      },
      {
        item: 'Prasad/Offering',
        fairPrice: '₹10-50',
        scamPrice: '₹100-500',
        warning: 'Optional, don\'t be pressured',
        icon: 'leaf'
      },
      {
        item: 'Pooja/Prayer Service',
        fairPrice: '₹51-501',
        scamPrice: '₹1000+',
        warning: 'Completely optional',
        icon: 'flame'
      }
    ],
    scams: [
      {
        title: 'Forced Donations',
        description: 'People pose as priests demanding donations. Donations are always optional.',
        severity: 'high',
        icon: 'hand-right'
      },
      {
        title: 'Tilak Scam',
        description: 'Apply tilak/blessing then demand high payment. Refuse or give small amount.',
        severity: 'medium',
        icon: 'hand-left'
      },
      {
        title: 'Flower Seller Scam',
        description: 'Sell overpriced flowers for offering. Buy outside temple if needed.',
        severity: 'low',
        icon: 'rose'
      },
      {
        title: 'Prasad Replacement',
        description: 'Claim free prasad is "special" and demand payment. Ignore and take free prasad.',
        severity: 'low',
        icon: 'gift'
      }
    ],
    tips: [
      'Donations and offerings are always optional',
      'Politely refuse anyone asking for money',
      'Dress modestly when visiting religious sites',
      'Most temples don\'t charge entry for prayer'
    ]
  },

  // General/Default for activities
  activity: {
    items: [
      {
        item: 'Taxi/Auto (per km)',
        fairPrice: '₹15-25',
        scamPrice: '₹50-100',
        warning: 'Use meter or agree on price beforehand',
        icon: 'car'
      },
      {
        item: 'Bottled Water',
        fairPrice: '₹20-40',
        scamPrice: '₹80-150',
        icon: 'water'
      },
      {
        item: 'Parking',
        fairPrice: '₹20-50',
        scamPrice: '₹100-200',
        warning: 'Use official parking only',
        icon: 'car'
      },
      {
        item: 'Public Restroom',
        fairPrice: '₹5-10',
        scamPrice: '₹20-50',
        icon: 'man'
      }
    ],
    scams: [
      {
        title: 'No Meter Taxi',
        description: 'Taxi refuses to use meter and quotes high price. Insist on meter or walk away.',
        severity: 'high',
        icon: 'car'
      },
      {
        title: 'Wrong Change',
        description: 'Vendors give wrong change claiming no small notes. Carry exact change.',
        severity: 'medium',
        icon: 'cash'
      }
    ],
    tips: [
      'Always carry small denominations',
      'Use official/marked taxis and autos',
      'Ask locals for fair price estimates'
    ]
  }
};

// Function to get price data based on activity/place details
export const getPriceAlerts = (
  place: string,
  description: string,
  category: string
): LocationPriceData => {
  const lowerPlace = place.toLowerCase();
  const lowerDesc = description.toLowerCase();
  const lowerCategory = category.toLowerCase();

  // Match based on place name and description
  if (lowerPlace.includes('beach') || lowerDesc.includes('beach')) {
    return priceDatabase.beach;
  }
  if (lowerPlace.includes('restaurant') || lowerPlace.includes('cafe') || lowerCategory === 'food') {
    return priceDatabase.restaurant;
  }
  if (lowerPlace.includes('fort') || lowerPlace.includes('church') || lowerPlace.includes('temple') ||
      lowerDesc.includes('heritage') || lowerDesc.includes('church')) {
    return priceDatabase.heritage;
  }
  if (lowerPlace.includes('market') || lowerPlace.includes('shop') || lowerDesc.includes('shopping')) {
    return priceDatabase.market;
  }
  if (lowerPlace.includes('kayak') || lowerPlace.includes('trek') || lowerPlace.includes('diving') ||
      lowerDesc.includes('adventure') || lowerDesc.includes('trek')) {
    return priceDatabase.adventure;
  }
  if (lowerPlace.includes('temple') || lowerPlace.includes('church') || lowerPlace.includes('mosque')) {
    return priceDatabase.temple;
  }

  // Default
  return priceDatabase.activity;
};

