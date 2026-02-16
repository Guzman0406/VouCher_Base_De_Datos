CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE "Frecuencia" AS ENUM ('Semanal', 'Quincenal', 'Mensual');
CREATE TYPE "CategoriaGasto" AS ENUM ('Vital', 'Recurrente');

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE "users" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

CREATE TABLE "user_configs" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "salario" DOUBLE PRECISION NOT NULL,
    "frecuencia" "Frecuencia" NOT NULL,
    "diaInicio" INTEGER NOT NULL,
    "saldoActual" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "ahorroHistorico" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "pendingConfig" JSONB,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    CONSTRAINT "user_configs_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "user_configs_userId_key" ON "user_configs"("userId");

CREATE TABLE "gastos" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "nombre" TEXT NOT NULL,
    "monto" DOUBLE PRECISION NOT NULL,
    "categoria" "CategoriaGasto" NOT NULL,
    "frecuencia" "Frecuencia" NOT NULL,
    "pagado" BOOLEAN NOT NULL DEFAULT FALSE,
    "canceladoParaElFuturo" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    CONSTRAINT "gastos_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "transacciones" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "nombre" TEXT NOT NULL,
    "monto" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    CONSTRAINT "transacciones_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ingresos_extra" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "monto" DOUBLE PRECISION NOT NULL,
    "origen" TEXT,
    "reservado" BOOLEAN NOT NULL DEFAULT FALSE,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    CONSTRAINT "ingresos_extra_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "metas" (
    "id" TEXT NOT NULL DEFAULT gen_random_uuid()::text,
    "nombre" TEXT NOT NULL,
    "objetivo" DOUBLE PRECISION NOT NULL,
    "acumulado" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    CONSTRAINT "metas_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "user_configs" ADD CONSTRAINT "user_configs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "gastos" ADD CONSTRAINT "gastos_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "transacciones" ADD CONSTRAINT "transacciones_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ingresos_extra" ADD CONSTRAINT "ingresos_extra_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "metas" ADD CONSTRAINT "metas_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;



CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON "users" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_configs_updated_at BEFORE UPDATE ON "user_configs" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gastos_updated_at BEFORE UPDATE ON "gastos" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_metas_updated_at BEFORE UPDATE ON "metas" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
