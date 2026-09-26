import { BadRequestException, ValidationError } from '@nestjs/common';


export const validationExceptionFactory = (
  validationErrors: ValidationError[],
): BadRequestException => {
  const errors: Record<string, string[]> = {};
  const collect = (items: ValidationError[], prefix = '') => {
    for (const item of items) {
      const key = prefix ? `${prefix}.${item.property}` : item.property;
      if (item.constraints) {
        errors[key] = Object.values(item.constraints);
      }
      if (item.children?.length) {
        collect(item.children, key);
      }
    }
  };
  collect(validationErrors);

  const first = Object.values(errors)[0]?.[0];
  return new BadRequestException({
    message: first ?? 'Validation failed',
    errors,
  });
};
