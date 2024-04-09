-- Limitar a 10 dígitos el número de teléfono
ALTER TABLE USUARIO ADD CONSTRAINT revisarTelefono CHECK(telefono<9999999999);

-- Limitar a 10 dígitos el número de cédula
ALTER TABLE USUARIO ADD CONSTRAINT revisarCedula CHECK(identificacion<9999999999);

-- Limitar a 5 dígitos el número de la extensión
ALTER TABLE UNIDAD ADD CONSTRAINT revisarExtension CHECK(extension<99999);
