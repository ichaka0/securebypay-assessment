import { TransformFnParams } from 'class-transformer';

/** class-transformer helpers for normalising incoming string fields. */
type Params = Omit<TransformFnParams, 'value'> & { value: unknown };

export const trim = ({ value }: Params): unknown =>
  typeof value === 'string' ? value.trim() : value;

export const trimLowerCase = ({ value }: Params): unknown =>
  typeof value === 'string' ? value.trim().toLowerCase() : value;

/** Removes spaces and dashes, e.g. `0901 234-5678` -> `09012345678`. */
export const stripPhoneSeparators = ({ value }: Params): unknown =>
  typeof value === 'string' ? value.replace(/[\s-]/g, '') : value;
