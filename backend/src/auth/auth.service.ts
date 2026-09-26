import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { DataSource, QueryFailedError } from 'typeorm';
import { ShipmentsService } from '../shipments/shipments.service';
import { UserResponseDto } from '../users/dto/user-response.dto';
import { User } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { AuthResponseDto } from './dto/auth-response.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './interfaces/auth-user.interface';

const BCRYPT_ROUNDS = 12;
const INVALID_CREDENTIALS = 'Invalid email or password';
/** Compared against when the email is unknown, so timing doesn't leak it. */
const DUMMY_HASH = bcrypt.hashSync('timing-safe-placeholder', BCRYPT_ROUNDS);
const PG_UNIQUE_VIOLATION = '23505';
const EMAIL_TAKEN = 'An account with this email already exists';

/** Handles account creation, credential checks and token issuing. */
@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly shipmentsService: ShipmentsService,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Creates a user and seeds demo shipments so the dashboard has content.
   * @throws ConflictException when the email is already registered.
   */
  async register(dto: RegisterDto): Promise<AuthResponseDto> {
    if (await this.usersService.emailExists(dto.email)) {
      throw new ConflictException(EMAIL_TAKEN);
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const user = await this.dataSource
      .transaction(async (manager) => {
        const created = await this.usersService.create(
          {
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email.toLowerCase(),
            phoneNumber: this.normalisePhone(dto.phoneNumber),
            passwordHash,
            walletBalance: 0,
          },
          manager,
        );
        await this.shipmentsService.seedDemoShipments(created, manager);
        return created;
      })
      .catch((error: unknown) => {
        // Two concurrent sign-ups with the same email: the pre-check above
        // passes for both, the unique index rejects the second.
        if (
          error instanceof QueryFailedError &&
          (error.driverError as { code?: string }).code === PG_UNIQUE_VIOLATION
        ) {
          throw new ConflictException(EMAIL_TAKEN);
        }
        throw error;
      });

    return this.buildAuthResponse(user);
  }

  /** @throws UnauthorizedException with a generic message on any mismatch. */
  async login(dto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.usersService.findByEmailWithPassword(dto.email);
    // Always run a bcrypt compare to keep response timing uniform.
    const matches = await bcrypt.compare(
      dto.password,
      user?.passwordHash ?? DUMMY_HASH,
    );
    if (!user || !matches) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }
    return this.buildAuthResponse(user);
  }

  async me(userId: string): Promise<UserResponseDto> {
    return UserResponseDto.fromEntity(await this.usersService.getById(userId));
  }

  /** Stores numbers in E.164 form, e.g. `09012345678` -> `+2349012345678`. */
  private normalisePhone(phone: string): string {
    const digits = phone.replace(/\D/g, '');
    const local = digits.replace(/^(234|0)/, '');
    return `+234${local}`;
  }

  private async buildAuthResponse(user: User): Promise<AuthResponseDto> {
    const payload: JwtPayload = { sub: user.id, email: user.email };
    return {
      accessToken: await this.jwtService.signAsync(payload),
      expiresIn: this.config.get<string>('jwt.expiresIn', '1d'),
      user: UserResponseDto.fromEntity(user),
    };
  }
}
