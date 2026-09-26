import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasswordResponseDto {
  @ApiProperty({ description: 'Single-use token to pass to /auth/reset-password' })
  resetToken: string;

  @ApiProperty({ example: 900, description: 'Seconds until the token expires' })
  expiresInSeconds: number;

  @ApiProperty({ example: 'Use the reset link to choose a new password.' })
  message: string;
}

export class MessageResponseDto {
  @ApiProperty({ example: 'Password updated. You can now sign in.' })
  message: string;
}
