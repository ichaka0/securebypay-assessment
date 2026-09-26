import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEmail } from 'class-validator';
import { trimLowerCase } from '../../common/transformers/string.transformers';

export class ForgotPasswordDto {
  @ApiProperty({ example: 'user@example.com' })
  @Transform(trimLowerCase)
  @IsEmail({}, { message: 'Enter a valid email address' })
  email: string;
}
