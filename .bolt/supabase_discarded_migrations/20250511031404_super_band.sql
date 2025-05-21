/*
  # Update RLS policies for admin access

  1. Changes
    - Remove existing admin policies that check specific email
    - Add new admin policies using is_admin() function
    - Update policies for all tables (destinations, places, packages, guides)
    
  2. Security
    - Create is_admin() function to check admin role
    - Enable RLS on all tables (already enabled)
    - Add policies for admin and public access
*/

-- Create is_admin() function for checking admin role
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    auth.jwt() ->> 'role' = 'admin'
    OR
    auth.jwt() ->> 'is_admin' = 'true'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update destinations table policies
DROP POLICY IF EXISTS "Allow admin full access" ON destinations;
CREATE POLICY "Enable full access for admins" 
ON destinations
TO public
USING (is_admin())
WITH CHECK (is_admin());

-- Update places table policies
DROP POLICY IF EXISTS "Allow admin full access" ON places;
CREATE POLICY "Enable full access for admins"
ON places
TO public
USING (is_admin())
WITH CHECK (is_admin());

-- Update packages table policies
DROP POLICY IF EXISTS "Allow admin full access" ON packages;
CREATE POLICY "Enable full access for admins"
ON packages
TO public
USING (is_admin())
WITH CHECK (is_admin());

-- Update guides table policies
DROP POLICY IF EXISTS "Allow admin full access" ON guides;
CREATE POLICY "Enable full access for admins"
ON guides
TO public
USING (is_admin())
WITH CHECK (is_admin());