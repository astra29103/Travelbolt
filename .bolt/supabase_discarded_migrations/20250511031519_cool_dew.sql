/*
  # Fix RLS policies for destinations table

  1. Changes
    - Drop existing RLS policies for destinations table
    - Add new policies that properly handle admin access:
      - Allow public read access
      - Enable full access for authenticated admin users
      - Ensure admin check uses proper auth.uid() function
  
  2. Security
    - Maintain public read access
    - Restrict write operations to admin users only
    - Use proper auth.jwt() claims checking
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read access" ON destinations;
DROP POLICY IF EXISTS "Enable full access for admins" ON destinations;

-- Create new policies
CREATE POLICY "Allow public read access"
ON destinations
FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable full access for admins"
ON destinations
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'role' = 'admin')
WITH CHECK (auth.jwt() ->> 'role' = 'admin');