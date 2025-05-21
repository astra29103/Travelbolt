/*
  # Initial Schema Setup

  1. New Tables
    - `destinations`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `category` (text)
      - `image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `places`
      - `id` (uuid, primary key) 
      - `destination_id` (uuid, foreign key)
      - `name` (text)
      - `description` (text)
      - `image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `packages`
      - `id` (uuid, primary key)
      - `destination_id` (uuid, foreign key)
      - `title` (text)
      - `description` (text)
      - `duration` (integer)
      - `price` (numeric)
      - `rating` (numeric)
      - `main_image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `package_images`
      - `id` (uuid, primary key)
      - `package_id` (uuid, foreign key)
      - `image_url` (text)
      - `created_at` (timestamp)

    - `package_places`
      - `package_id` (uuid, foreign key)
      - `place_id` (uuid, foreign key)
      - Primary key (package_id, place_id)

    - `guides`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text, unique)
      - `experience_years` (integer)
      - `languages` (text[])
      - `rating` (numeric)
      - `price_per_day` (numeric)
      - `image_url` (text)
      - `destination_id` (uuid, foreign key)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `bookings`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `package_id` (uuid, foreign key)
      - `guide_id` (uuid, foreign key)
      - `start_date` (date)
      - `end_date` (date)
      - `total_cost` (numeric)
      - `status` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users and admins
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create destinations table
CREATE TABLE destinations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create places table
CREATE TABLE places (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create packages table
CREATE TABLE packages (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL,
  duration integer NOT NULL,
  price numeric NOT NULL,
  rating numeric DEFAULT 0,
  main_image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create package_images table
CREATE TABLE package_images (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create package_places junction table
CREATE TABLE package_places (
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  place_id uuid REFERENCES places(id) ON DELETE CASCADE,
  PRIMARY KEY (package_id, place_id)
);

-- Create guides table
CREATE TABLE guides (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  email text UNIQUE NOT NULL,
  experience_years integer NOT NULL,
  languages text[] NOT NULL,
  rating numeric DEFAULT 0,
  price_per_day numeric NOT NULL,
  image_url text NOT NULL,
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create bookings table
CREATE TABLE bookings (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  guide_id uuid REFERENCES guides(id) ON DELETE CASCADE,
  start_date date NOT NULL,
  end_date date NOT NULL,
  total_cost numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create policies for destinations
CREATE POLICY "Allow public read access" ON destinations
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON destinations
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for places
CREATE POLICY "Allow public read access" ON places
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON places
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for packages
CREATE POLICY "Allow public read access" ON packages
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON packages
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for package_images
CREATE POLICY "Allow public read access" ON package_images
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON package_images
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for package_places
CREATE POLICY "Allow public read access" ON package_places
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON package_places
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for guides
CREATE POLICY "Allow public read access" ON guides
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON guides
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create policies for bookings
CREATE POLICY "Allow users to view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Allow users to create bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow admin full access" ON bookings
  FOR ALL USING (auth.jwt() ->> 'email' IN (SELECT email FROM auth.users WHERE raw_user_meta_data->>'isAdmin' = 'true'));

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_destinations_updated_at
    BEFORE UPDATE ON destinations
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_places_updated_at
    BEFORE UPDATE ON places
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_packages_updated_at
    BEFORE UPDATE ON packages
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_guides_updated_at
    BEFORE UPDATE ON guides
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();