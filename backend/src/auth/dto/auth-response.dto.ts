import { ApiProperty } from '@nestjs/swagger';
import { UserResponseDto } from '../../users/dto/user-response.dto';

export class AuthResponseDto {
  @ApiProperty({ description: 'JWT bearer token' })
  accessToken: string;

  @ApiProperty({ example: '1d' })
  expiresIn: string;

  @ApiProperty({ type: UserResponseDto })
  user: UserResponseDto;
}
