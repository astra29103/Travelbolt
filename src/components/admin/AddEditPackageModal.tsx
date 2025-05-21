import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import type { Tables } from '../../lib/supabase';
import { useDestinations } from '../../hooks/useDestinations';
import { supabase } from '../../lib/supabase';

interface Props {
  package?: any;
  destinationId: string;
  onClose: () => void;
  onSave: (data: any) => Promise<void>;
}

export const AddEditPackageModal: React.FC<Props> = ({ 
  package: pkg, 
  destinationId: initialDestinationId, 
  onClose, 
  onSave 
}) => {
  const [title, setTitle] = useState(pkg?.title || '');
  const [description, setDescription] = useState(pkg?.description || '');
  const [duration, setDuration] = useState(pkg?.duration?.toString() || '');
  const [price, setPrice] = useState(pkg?.price?.toString() || '');
  const [mainImageUrl, setMainImageUrl] = useState(pkg?.main_image_url || '');
  const [selectedDestinationId, setSelectedDestinationId] = useState(initialDestinationId || pkg?.destination_id || '');
  const [itineraryDescriptions, setItineraryDescriptions] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const { destinations } = useDestinations();

  useEffect(() => {
    if (pkg?.id) {
      fetchExistingItinerary();
    }
  }, [pkg?.id]);

  useEffect(() => {
    const days = parseInt(duration) || 0;
    if (days > 0) {
      setItineraryDescriptions(prev => {
        const newDescriptions = [...prev];
        // Keep existing descriptions if available
        while (newDescriptions.length < days) {
          newDescriptions.push('');
        }
        // Remove extra descriptions if duration is reduced
        if (newDescriptions.length > days) {
          newDescriptions.length = days;
        }
        return newDescriptions;
      });
    } else {
      setItineraryDescriptions([]);
    }
  }, [duration]);

  const fetchExistingItinerary = async () => {
    if (!pkg?.id) return;

    try {
      const { data, error } = await supabase
        .from('package_itinerary')
        .select('*')
        .eq('package_id', pkg.id)
        .maybeSingle();

      if (error) {
        console.error('Error fetching itinerary:', error);
        return;
      }

      if (data) {
        setItineraryDescriptions(data.description || []);
      }
    } catch (err) {
      console.error('Error fetching itinerary:', err);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // Validate required fields
      if (!selectedDestinationId) {
        throw new Error('Please select a destination');
      }

      if (!title.trim()) {
        throw new Error('Title is required');
      }

      if (!description.trim()) {
        throw new Error('Description is required');
      }

      if (!duration || parseInt(duration) <= 0) {
        throw new Error('Valid duration is required');
      }

      if (!price || parseFloat(price) <= 0) {
        throw new Error('Valid price is required');
      }

      if (!mainImageUrl.trim()) {
        throw new Error('Main image URL is required');
      }

      // Validate itinerary descriptions
      if (itineraryDescriptions.length === 0) {
        throw new Error('At least one itinerary day is required');
      }

      if (itineraryDescriptions.some(desc => !desc.trim())) {
        throw new Error('Please fill in all itinerary descriptions');
      }

      const packageData = {
        ...(pkg?.id ? { id: pkg.id } : {}),
        destination_id: selectedDestinationId,
        title: title.trim(),
        description: description.trim(),
        duration: parseInt(duration),
        price: parseFloat(price),
        main_image_url: mainImageUrl.trim(),
        rating: pkg?.rating || 0
      };

      await onSave({
        ...packageData,
        itineraryDescriptions: itineraryDescriptions.map(desc => desc.trim())
      });

      onClose();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred while saving');
    } finally {
      setLoading(false);
    }
  };

  const handleItineraryChange = (index: number, value: string) => {
    setItineraryDescriptions(prev => {
      const newDescriptions = [...prev];
      newDescriptions[index] = value;
      return newDescriptions;
    });
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg w-full max-w-4xl p-6 max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">
            {pkg ? 'Edit Package' : 'Add Package'}
          </h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 text-red-700 rounded-lg">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Destination
              </label>
              <select
                value={selectedDestinationId}
                onChange={(e) => setSelectedDestinationId(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-lg"
                required
              >
                <option value="">Select destination</option>
                {destinations.map((dest) => (
                  <option key={dest.id} value={dest.id}>{dest.name}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Title
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-lg"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full p-2 border border-gray-300 rounded-lg"
              rows={3}
              required
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Duration (days)
              </label>
              <input
                type="number"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-lg"
                min="1"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Price
              </label>
              <input
                type="number"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                className="w-full p-2 border border-gray-300 rounded-lg"
                min="0"
                step="0.01"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Main Image URL
            </label>
            <input
              type="url"
              value={mainImageUrl}
              onChange={(e) => setMainImageUrl(e.target.value)}
              className="w-full p-2 border border-gray-300 rounded-lg"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              Day-by-Day Itinerary
            </label>
            <div className="space-y-4">
              {itineraryDescriptions.map((desc, index) => (
                <div key={index}>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Day {index + 1}
                  </label>
                  <textarea
                    value={desc}
                    onChange={(e) => handleItineraryChange(index, e.target.value)}
                    className="w-full p-2 border border-gray-300 rounded-lg"
                    rows={2}
                    placeholder={`Enter itinerary for day ${index + 1}`}
                    required
                  />
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-end space-x-3">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-700 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className={`px-4 py-2 text-white rounded-lg ${
                loading
                  ? 'bg-gray-400 cursor-not-allowed'
                  : 'bg-cyan-600 hover:bg-cyan-700'
              }`}
            >
              {loading ? 'Saving...' : 'Save'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};