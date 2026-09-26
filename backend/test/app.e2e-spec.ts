import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { App } from 'supertest/types';
import { DataSource } from 'typeorm';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { AuthResponseDto } from '../src/auth/dto/auth-response.dto';
import { ErrorResponseBody } from '../src/common/filters/http-exception.filter';
import {
  GrowthResponseDto,
  OverviewResponseDto,
} from '../src/dashboard/dto/dashboard-response.dto';
import {
  PaginatedShipmentsDto,
  PayShipmentResponseDto,
} from '../src/shipments/dto/shipment-response.dto';
import { UserResponseDto } from '../src/users/dto/user-response.dto';

/** Typed access to a supertest response body. */
const bodyOf = <T>(res: request.Response): T => res.body as T;

/**
 * Full-stack flow against a real PostgreSQL database (configured via .env).
 * Uses a unique email per run and deletes the user afterwards.
 */
describe('Auth & dashboard (e2e)', () => {
  let app: INestApplication<App>;
  const email = `e2e-${Date.now()}@example.com`;
  const password = 'Secret123';
  let token: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app
      .get(DataSource)
      .query('DELETE FROM users WHERE email = $1', [email]);
    await app.close();
  });

  it('rejects invalid sign-up payloads with field errors', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        firstName: '',
        lastName: 'Doe',
        email: 'bad',
        phoneNumber: '1',
        password: 'short',
      })
      .expect(400);
    const { errors } = bodyOf<ErrorResponseBody>(res);
    expect(errors).toHaveProperty('email');
    expect(errors).toHaveProperty('password');
    expect(errors).toHaveProperty('phoneNumber');
  });

  it('registers a new user', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        firstName: 'Jane',
        lastName: 'Doe',
        email,
        phoneNumber: '9012345678',
        password,
      })
      .expect(201);
    const body = bodyOf<AuthResponseDto>(res);
    expect(body.accessToken).toEqual(expect.any(String));
    expect(body.user.email).toBe(email);
  });

  it('rejects a duplicate email', () =>
    request(app.getHttpServer())
      .post('/api/auth/register')
      .send({
        firstName: 'Jane',
        lastName: 'Doe',
        email,
        phoneNumber: '9012345678',
        password,
      })
      .expect(409));

  it('rejects a wrong password', () =>
    request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email, password: 'Wrong1234' })
      .expect(401));

  it('logs in and fetches the profile', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email, password })
      .expect(200);
    token = bodyOf<AuthResponseDto>(res).accessToken;

    const me = await request(app.getHttpServer())
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    expect(bodyOf<UserResponseDto>(me).email).toBe(email);
  });

  it('blocks protected routes without a token', () =>
    request(app.getHttpServer()).get('/api/dashboard/overview').expect(401));

  it('serves dashboard data, funds the wallet and pays a shipment', async () => {
    const auth = { Authorization: `Bearer ${token}` };
    const server = app.getHttpServer();

    const overview = await request(server)
      .get('/api/dashboard/overview?period=month')
      .set(auth)
      .expect(200);
    expect(
      bodyOf<OverviewResponseDto>(overview).totalShipments.value,
    ).toBeGreaterThan(0);

    const growth = await request(server)
      .get('/api/dashboard/growth?range=year')
      .set(auth)
      .expect(200);
    expect(bodyOf<GrowthResponseDto>(growth).points).toHaveLength(12);

    const list = await request(server)
      .get('/api/shipments?limit=3')
      .set(auth)
      .expect(200);
    const unpaid = bodyOf<PaginatedShipmentsDto>(list).items.find(
      (s) => !s.isPaid,
    );
    if (!unpaid) throw new Error('Expected an unpaid demo shipment');

    await request(server)
      .post(`/api/shipments/${unpaid.id}/pay`)
      .set(auth)
      .expect(400);
    await request(server)
      .post('/api/wallet/fund')
      .set(auth)
      .send({ amount: 10000 })
      .expect(200);
    const paid = await request(server)
      .post(`/api/shipments/${unpaid.id}/pay`)
      .set(auth)
      .expect(200);
    expect(bodyOf<PayShipmentResponseDto>(paid).walletBalance).toBe(
      10000 - unpaid.amount,
    );
  });
});
