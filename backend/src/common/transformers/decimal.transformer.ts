import { ValueTransformer } from 'typeorm';

/**
 * Postgres returns `numeric` columns as strings to avoid precision loss.
 * Money values here fit comfortably in a JS number, so convert on read.
 */
export const decimalTransformer: ValueTransformer = {
  to: (value?: number | null) => value,
  from: (value?: string | null) => (value == null ? value : parseFloat(value)),
};
