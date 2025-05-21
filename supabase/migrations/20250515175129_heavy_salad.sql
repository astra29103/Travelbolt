/*
  # Update packages table and create destination places

  1. Changes
    - Add itinerary column to packages table
    - Create destination_places table
  
  2. New Tables
    - destination_places
      - id (uuid, primary key)
      - destination_id (uuid, foreign key)
      - name (text)
      - description (text)
      - image_url (text)
      - created_at (timestamp)
      - updated_at (timestamp)
*/

-- Add itinerary column to packages table
ALTER TABLE packages 
ADD COLUMN itinerary text;

-- Create destination_places table
CREATE TABLE IF NOT EXISTS destination_places (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index on destination_id
CREATE INDEX idx_destination_places_destination ON destination_places(destination_id);

-- Enable RLS
ALTER TABLE destination_places ENABLE ROW LEVEL SECURITY;

-- Create trigger for updated_at
CREATE TRIGGER update_destination_places_updated_at
  BEFORE UPDATE ON destination_places
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();