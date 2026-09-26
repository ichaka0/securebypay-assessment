import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}

  findById(id: string): Promise<User | null> {
    return this.users.findOne({ where: { id } });
  }

  async getById(id: string): Promise<User> {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  findByEmail(email: string): Promise<User | null> {
    return this.users.findOne({ where: { email: email.toLowerCase() } });
  }

  findByEmailWithPassword(email: string): Promise<User | null> {
    return this.users
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .where('user.email = :email', { email: email.toLowerCase() })
      .getOne();
  }

  findByResetTokenHash(hash: string): Promise<User | null> {
    return this.users
      .createQueryBuilder('user')
      .addSelect('user.resetTokenExpiresAt')
      .where('user.resetTokenHash = :hash', { hash })
      .getOne();
  }

  async emailExists(email: string): Promise<boolean> {
    return this.users.exists({ where: { email: email.toLowerCase() } });
  }

  async setResetToken(
    userId: string,
    hash: string,
    expiresAt: Date,
  ): Promise<void> {
    await this.users.update(userId, {
      resetTokenHash: hash,
      resetTokenExpiresAt: expiresAt,
    });
  }

  async completePasswordReset(
    userId: string,
    passwordHash: string,
  ): Promise<void> {
    await this.users.update(userId, {
      passwordHash,
      resetTokenHash: null,
      resetTokenExpiresAt: null,
    });
  }

  create(data: Partial<User>, manager?: EntityManager): Promise<User> {
    const repo = manager ? manager.getRepository(User) : this.users;
    return repo.save(repo.create(data));
  }

  /** Atomically adds `amount` (may be negative) to the wallet balance. */
  async adjustWalletBalance(
    userId: string,
    amount: number,
    manager?: EntityManager,
  ): Promise<void> {
    const repo = manager ? manager.getRepository(User) : this.users;
    await repo.increment({ id: userId }, 'walletBalance', amount);
  }
}
