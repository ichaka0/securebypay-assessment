import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import {
  stripPhoneSeparators,
  trim,
  trimLowerCase,
} from '../../common/transformers/string.transformers';

/** Nigerian mobile number: optional +234/234/0 prefix, then 10 digits. */
export const NIGERIAN_PHONE_REGEX = /^(?:\+?234|0)?[789][01]\d{8}$/;

/** Password rule shared with the frontend: 8+ chars, a letter and a digit. */
export const PASSWORD_REGEX = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;

export class RegisterDto {
  @ApiProperty({ example: 'John' })
  @Transform(trim)
  @IsString()
  @IsNotEmpty({ message: 'First name is required' })
  @MaxLength(100)
  firstName: string;

  @ApiProperty({ example: 'Doe' })
  @Transform(trim)
  @IsString()
  @IsNotEmpty({ message: 'Last name is required' })
  @MaxLength(100)
  lastName: string;

  @ApiProperty({ example: 'user@example.com' })
  @Transform(trimLowerCase)
  @IsEmail({}, { message: 'Enter a valid email address' })
  @MaxLength(255)
  email: string;

  @ApiProperty({ example: '9012345678', description: 'Nigerian mobile number' })
  @Transform(stripPhoneSeparators)
  @IsString()
  @Matches(NIGERIAN_PHONE_REGEX, {
    message: 'Enter a valid Nigerian phone number',
  })
  phoneNumber: string;

  @ApiProperty({ example: 'Secret123', minLength: 8 })
  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @MaxLength(72, { message: 'Password must be at most 72 characters' })
  @Matches(PASSWORD_REGEX, {
    message: 'Password must contain at least one letter and one number',
  })
  password: string;
}
