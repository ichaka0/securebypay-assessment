import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import * as bcrypt from 'bcrypt';
import { DataSource } from 'typeorm';
import { ShipmentsService } from '../shipments/shipments.service';
import { User } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';

describe('AuthService', () => {
  let service: AuthService;
  const usersService = {
    emailExists: jest.fn(),
    create: jest.fn(),
    findByEmailWithPassword: jest.fn(),
    getById: jest.fn(),
  };
  const shipmentsService = { seedDemoShipments: jest.fn() };
  const jwtService = { signAsync: jest.fn().mockResolvedValue('signed.jwt') };
  const dataSource = {
    transaction: jest.fn((cb: (m: unknown) => unknown) => cb({})),
  };

  const registerDto: RegisterDto = {
    firstName: 'John',
    lastName: 'Doe',
    email: 'John@Example.com',
    phoneNumber: '09012345678',
    password: 'Secret123',
  };

  const makeUser = (overrides: Partial<User> = {}): User =>
    ({
      id: 'user-1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phoneNumber: '+2349012345678',
      walletBalance: 0,
      createdAt: new Date(),
      ...overrides,
    }) as User;

  beforeEach(async () => {
    jest.clearAllMocks();
    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: ShipmentsService, useValue: shipmentsService },
        { provide: JwtService, useValue: jwtService },
        { provide: ConfigService, useValue: { get: () => '1d' } },
        { provide: DataSource, useValue: dataSource },
      ],
    }).compile();
    service = moduleRef.get(AuthService);
  });

  describe('register', () => {
    it('creates the user with a hashed password and normalised fields', async () => {
      usersService.emailExists.mockResolvedValue(false);
      usersService.create.mockImplementation((data: Partial<User>) =>
        Promise.resolve(makeUser(data)),
      );

      const result = await service.register(registerDto);

      const [[created]] = usersService.create.mock.calls as [[Partial<User>]];
      expect(created.email).toBe('john@example.com');
      expect(created.phoneNumber).toBe('+2349012345678');
      expect(created.passwordHash).not.toBe(registerDto.password);
      expect(await bcrypt.compare('Secret123', created.passwordHash!)).toBe(
        true,
      );
      expect(shipmentsService.seedDemoShipments).toHaveBeenCalled();
      expect(result.accessToken).toBe('signed.jwt');
      expect(result.user).not.toHaveProperty('passwordHash');
    });

    it('rejects a duplicate email with 409', async () => {
      usersService.emailExists.mockResolvedValue(true);
      await expect(service.register(registerDto)).rejects.toBeInstanceOf(
        ConflictException,
      );
      expect(usersService.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    it('returns a token for valid credentials', async () => {
      const passwordHash = await bcrypt.hash('Secret123', 4);
      usersService.findByEmailWithPassword.mockResolvedValue(
        makeUser({ passwordHash }),
      );
      const result = await service.login({
        email: 'john@example.com',
        password: 'Secret123',
      });
      expect(result.accessToken).toBe('signed.jwt');
      expect(result.user.email).toBe('john@example.com');
    });

    it('rejects a wrong password', async () => {
      const passwordHash = await bcrypt.hash('Secret123', 4);
      usersService.findByEmailWithPassword.mockResolvedValue(
        makeUser({ passwordHash }),
      );
      await expect(
        service.login({ email: 'john@example.com', password: 'Wrong1234' }),
      ).rejects.toThrow(new UnauthorizedException('Invalid email or password'));
    });

    it('rejects an unknown email with the same message', async () => {
      usersService.findByEmailWithPassword.mockResolvedValue(null);
      await expect(
        service.login({ email: 'nobody@example.com', password: 'Secret123' }),
      ).rejects.toThrow(new UnauthorizedException('Invalid email or password'));
    });
  });
});
