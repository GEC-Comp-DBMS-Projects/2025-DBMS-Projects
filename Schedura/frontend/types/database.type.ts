export type Database = {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          email: string;
          name: string;
          avatar_url?: string;
          role: 'owner' | 'user';
          created_at: string;
        };
      };
      spaces: {
        Row: {
            id: string | null | undefined;
            name: string,
            capacity: number,
            location: string,
            latitude?: number,
            longitude?: number,
            description: string,
            pph: string, // or a number if column type changes
            ownerid: string,
            organizationid?: number,
            updated_at?: string | null;
            category?: 'Wedding' | 'Corporate' | 'Birthday' | 'Conference' | 'Social';
            amenities?: string[];
        };
      };
      organisations: {
        Row: {
          id: string;
          ownerid: string;
          name: string;
          description: string;
          type: 'Educational' | 'CoWorking';
          logo?: string;
          created_at: string;
        };
      };
      user_organisations: {
        Row: {
          id: string;
          user_id: string;
          organisation_id: string;
          role?: 'owner' | 'admin' | 'member';
          created_at: string;
        };
      };
      join_requests: {
        Row: {
          id: string;
          user_id: string;
          organisation_id: string;
          status: 'pending' | 'approved' | 'rejected';
          requested_role?: 'admin' | 'member';
          message?: string;
          created_at: string;
          updated_at?: string;
        };
      };      
    };
  };
};

export type UserProfile = Database['public']['Tables']['users']['Row'];
export type Space = Database['public']['Tables']['spaces']['Row'];
export type Organisation = Database['public']['Tables']['organisations']['Row'];
export type UserOrganisation = Database['public']['Tables']['user_organisations']['Row'];
export type JoinRequest = Database['public']['Tables']['join_requests']['Row'];