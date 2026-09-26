import * as Joi from 'joi';

/** Required only when the database isn't configured through DATABASE_URL. */
const requiredWithoutUrl = (schema: Joi.StringSchema) =>
  schema.when('DATABASE_URL', {
    is: Joi.exist(),
    then: Joi.optional(),
    otherwise: Joi.required(),
  });

/**
 * Schema used by ConfigModule to validate environment variables at boot.
 * The app refuses to start if a required variable is missing or malformed.
 */
export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  PORT: Joi.number().port().default(3000),

  // Hosted Postgres (e.g. Neon): a full connection string. When set it takes
  // precedence over the DB_* variables below.
  DATABASE_URL: Joi.string()
    .uri({ scheme: ['postgres', 'postgresql'] })
    .messages({
      'string.uriCustomScheme':
        'DATABASE_URL must be a bare postgres:// or postgresql:// URL ' +
        '(without a leading `psql` or surrounding quotes)',
    }),

  // Local Postgres: individual connection settings.
  DB_HOST: Joi.string().default('localhost'),
  DB_PORT: Joi.number().port().default(5432),
  DB_USERNAME: requiredWithoutUrl(Joi.string()),
  DB_PASSWORD: Joi.string().allow('').default(''),
  DB_NAME: requiredWithoutUrl(Joi.string()),
  DB_SSL: Joi.boolean().default(false),

  JWT_SECRET: Joi.string().min(16).required(),
  JWT_EXPIRES_IN: Joi.string().default('1d'),

  // Browser origins allowed by CORS. FRONTEND_URL is the deployed web app;
  // CORS_ORIGIN adds extra comma-separated origins (e.g. local dev).
  FRONTEND_URL: Joi.string()
    .uri({ scheme: ['http', 'https'] })
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional(),
    }),
  CORS_ORIGIN: Joi.string().allow('').default(''),
});
