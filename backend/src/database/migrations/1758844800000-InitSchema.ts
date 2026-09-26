import { MigrationInterface, QueryRunner } from 'typeorm';

/** Creates the `users` and `shipments` tables. */
export class InitSchema1758844800000 implements MigrationInterface {
  name = 'InitSchema1758844800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

    await queryRunner.query(`
      CREATE TABLE "users" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "first_name" character varying(100) NOT NULL,
        "last_name" character varying(100) NOT NULL,
        "email" character varying(255) NOT NULL,
        "phone_number" character varying(20) NOT NULL,
        "password_hash" character varying NOT NULL,
        "wallet_balance" numeric(14,2) NOT NULL DEFAULT '0',
        CONSTRAINT "PK_users_id" PRIMARY KEY ("id")
      )`);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_users_email" ON "users" ("email")`,
    );

    await queryRunner.query(
      `CREATE TYPE "shipments_status_enum" AS ENUM('pending_payment', 'in_transit', 'delayed', 'delivered')`,
    );
    await queryRunner.query(
      `CREATE TYPE "shipments_type_enum" AS ENUM('export', 'import')`,
    );
    await queryRunner.query(`
      CREATE TABLE "shipments" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
        "tracking_id" character varying(32) NOT NULL,
        "sender" character varying(150) NOT NULL,
        "receiver" character varying(150) NOT NULL,
        "pickup_from" character varying(150) NOT NULL,
        "delivery_to" character varying(150) NOT NULL,
        "pickup_country" character varying(2) NOT NULL DEFAULT 'NG',
        "delivery_country" character varying(2) NOT NULL DEFAULT 'NG',
        "amount" numeric(14,2) NOT NULL,
        "status" "shipments_status_enum" NOT NULL,
        "type" "shipments_type_enum" NOT NULL,
        "processing_hours" integer NOT NULL,
        "is_paid" boolean NOT NULL DEFAULT false,
        "shipped_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        "user_id" uuid NOT NULL,
        CONSTRAINT "PK_shipments_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_shipments_user" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )`);
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_shipments_tracking_id" ON "shipments" ("tracking_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_shipments_user_id" ON "shipments" ("user_id")`,
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_shipments_shipped_at" ON "shipments" ("shipped_at")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "shipments"`);
    await queryRunner.query(`DROP TYPE "shipments_type_enum"`);
    await queryRunner.query(`DROP TYPE "shipments_status_enum"`);
    await queryRunner.query(`DROP TABLE "users"`);
  }
}
