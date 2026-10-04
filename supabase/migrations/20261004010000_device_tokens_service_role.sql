-- El proyecto no concede permisos automáticos a tablas nuevas:
-- push-send lee y limpia tokens con service_role.
grant select, delete on public.device_tokens to service_role;
