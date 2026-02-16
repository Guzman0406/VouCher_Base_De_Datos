-- Users Queries
SELECT * FROM "users" WHERE email = $1;

INSERT INTO "users" (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email;

-- Config Queries
SELECT "userId" FROM "user_configs" WHERE "diaInicio" = $1;

SELECT * FROM "user_configs" WHERE "userId" = $1;

SELECT "monto" FROM "ingresos_extra" WHERE "userId" = $1 AND "reservado" = true;

UPDATE "user_configs" 
SET "salario" = $1, "frecuencia" = $2, "diaInicio" = $3, "saldoActual" = $4, "pendingConfig" = NULL 
WHERE "userId" = $5;

-- Gastos Management
INSERT INTO "gastos" ("userId", "nombre", "monto", "categoria", "frecuencia", "pagado")
VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;

SELECT * FROM "gastos" WHERE "userId" = $1 ORDER BY "createdAt" DESC;

UPDATE "gastos" SET "pagado" = $1 WHERE "id" = $2 RETURNING *;

-- Saving Goals
UPDATE "user_configs" SET "saldoActual" = "saldoActual" - $1 WHERE "userId" = $2;

INSERT INTO "metas" ("userId", "nombre", "objetivo", "acumulado")
VALUES ($1, $2, $3, $4) RETURNING *;

UPDATE "metas" SET "acumulado" = "acumulado" + $1 WHERE "id" = $2 RETURNING *;

-- Dashboard
SELECT 
    u.id AS usuario_id,
    u.name AS nombre_usuario,
    COUNT(m.id) AS total_metas,
    SUM(m.objetivo) AS suma_objetivos,
    SUM(m.acumulado) AS suma_acumulada,
    (SELECT COALESCE(AVG(g.monto), 0) FROM gastos g WHERE g."userId" = u.id) AS gasto_promedio
FROM 
    users u
JOIN 
    metas m ON u.id = m."userId"
GROUP BY 
    u.id, u.name;

-- Salud del sistema
SELECT 1;

-- Vista de rendimiento de metas
CREATE OR REPLACE VIEW vista_rendimiento_metas AS
SELECT 
    u.id AS usuario_id,
    u.name AS nombre_usuario,
    COUNT(m.id) AS total_metas,
    SUM(m.objetivo) AS suma_objetivos,
    SUM(m.acumulado) AS suma_acumulada,
    (SELECT COALESCE(AVG(g.monto), 0) FROM gastos g WHERE g."userId" = u.id) AS gasto_promedio
FROM 
    users u
JOIN 
    metas m ON u.id = m."userId"
GROUP BY 
    u.id, u.name
HAVING 
    SUM(m.acumulado) > 0
ORDER BY 
    suma_acumulada DESC;

-- Gestión de roles
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'vaucher_readonly') THEN
      CREATE ROLE vaucher_readonly WITH LOGIN PASSWORD 'readonly_pass';
   END IF;
END
$do$;
