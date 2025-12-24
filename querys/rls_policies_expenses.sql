-- Policy: Enable all for authenticated users
CREATE POLICY "Enable all for authenticated users"
ON public.expenses
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Policy: Enable read for anon
CREATE POLICY "Enable read for anon"
ON public.expenses
FOR SELECT
USING (true);