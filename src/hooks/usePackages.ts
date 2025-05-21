import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { Tables } from '../lib/supabase';

export function usePackages(destinationId?: string) {
  const [packages, setPackages] = useState<Tables['packages'][]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchPackages = async () => {
    try {
      let query = supabase
        .from('packages')
        .select('*')
        .order('created_at', { ascending: false });

      if (destinationId) {
        query = query.eq('destination_id', destinationId);
      }

      const { data, error } = await query;

      if (error) throw error;
      setPackages(data || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const addPackage = async (pkg: Omit<Tables['packages'], 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const { data: packageData, error: packageError } = await supabase
        .from('packages')
        .insert([pkg])
        .select()
        .single();

      if (packageError) throw packageError;

      setPackages(prev => [packageData, ...prev]);
      return packageData;
    } catch (err) {
      console.error('Error adding package:', err);
      throw err;
    }
  };

  const updatePackage = async (id: string, updates: Partial<Tables['packages']>) => {
    try {
      const { data: packageData, error: packageError } = await supabase
        .from('packages')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (packageError) throw packageError;

      setPackages(prev => prev.map(p => p.id === id ? packageData : p));
      return packageData;
    } catch (err) {
      console.error('Error updating package:', err);
      throw err;
    }
  };

  const deletePackage = async (id: string) => {
    try {
      const { error } = await supabase
        .from('packages')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setPackages(prev => prev.filter(p => p.id !== id));
    } catch (err) {
      console.error('Error deleting package:', err);
      throw err;
    }
  };

  const addOrUpdateItinerary = async (packageId: string, itineraryData: { description: string[] }) => {
    try {
      // First check if an itinerary exists
      const { data: existingData } = await supabase
        .from('package_itinerary')
        .select('id')
        .eq('package_id', packageId)
        .maybeSingle();

      if (existingData) {
        // Update existing itinerary
        const { error } = await supabase
          .from('package_itinerary')
          .update({
            description: itineraryData.description
          })
          .eq('package_id', packageId);

        if (error) throw error;
      } else {
        // Create new itinerary
        const { error } = await supabase
          .from('package_itinerary')
          .insert([{
            package_id: packageId,
            no_of_days: itineraryData.description.length,
            description: itineraryData.description
          }]);

        if (error) throw error;
      }
    } catch (err) {
      console.error('Error saving itinerary:', err);
      throw err;
    }
  };

  const getItinerary = async (packageId: string) => {
    try {
      const { data, error } = await supabase
        .from('package_itinerary')
        .select('*')
        .eq('package_id', packageId)
        .maybeSingle();

      if (error) throw error;
      return data;
    } catch (err) {
      console.error('Error fetching itinerary:', err);
      throw err;
    }
  };

  const addOrUpdatePackageWithItinerary = async (
    pkg: Omit<Tables['packages'], 'id' | 'created_at' | 'updated_at'> & { id?: string },
    itineraryDescriptions: string[]
  ) => {
    try {
      // Validate itinerary descriptions
      if (!itineraryDescriptions || itineraryDescriptions.length === 0) {
        throw new Error('Itinerary descriptions are required');
      }

      if (itineraryDescriptions.some(desc => !desc.trim())) {
        throw new Error('All itinerary descriptions must be filled out');
      }

      let savedPackage: Tables['packages'];
      
      if (pkg.id) {
        // Update existing package
        savedPackage = await updatePackage(pkg.id, pkg);
      } else {
        // Add new package
        savedPackage = await addPackage(pkg);
      }

      // Save itinerary
      await addOrUpdateItinerary(savedPackage.id, {
        description: itineraryDescriptions
      });

      return savedPackage;
    } catch (err) {
      console.error('Error saving package with itinerary:', err);
      throw err;
    }
  };

  useEffect(() => {
    fetchPackages();
  }, [destinationId]);

  return {
    packages,
    loading,
    error,
    addPackage,
    updatePackage,
    deletePackage,
    addOrUpdateItinerary,
    getItinerary,
    addOrUpdatePackageWithItinerary,
    refetch: fetchPackages
  };
}