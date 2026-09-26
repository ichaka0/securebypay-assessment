import { randomInt } from 'crypto';
import { ShipmentStatus, ShipmentType } from './entities/shipment.entity';

/** Fields needed to create a demo shipment (user and ids are added later). */
export interface DemoShipmentSeed {
  trackingId: string;
  sender: string;
  receiver: string;
  pickupFrom: string;
  pickupCountry: string;
  deliveryTo: string;
  deliveryCountry: string;
  amount: number;
  status: ShipmentStatus;
  type: ShipmentType;
  processingHours: number;
  isPaid: boolean;
  shippedAt: Date;
}

const SENDERS = ['Bunmi Tanny', 'Tolu Adebayo', 'Chidi Okafor', 'Aisha Bello'];
const RECEIVERS = ['Mercy', 'David Mensah', 'Grace Eze', 'Samuel Obi'];
const LOCAL_CITIES = [
  'Lagos, Nigeria',
  'Oyo Nigeria',
  'Abuja, Nigeria',
  'Kano, Nigeria',
];
const FOREIGN: Array<[string, string]> = [
  ['London, United Kingdom', 'GB'],
  ['Houston, United States', 'US'],
  ['Accra, Ghana', 'GH'],
  ['Toronto, Canada', 'CA'],
];
const STATUSES = [
  ShipmentStatus.IN_TRANSIT,
  ShipmentStatus.DELAYED,
  ShipmentStatus.DELIVERED,
];

const DAY_MS = 24 * 60 * 60 * 1000;

const pick = <T>(items: readonly T[]): T => items[randomInt(items.length)];

/** Generates a tracking id in the design's `MAF-100-234-291` format. */
export const generateTrackingId = (): string =>
  `MAF-${randomInt(100, 1000)}-${randomInt(100, 1000)}-${randomInt(100, 1000)}`;

/**
 * Builds a realistic spread of shipments over the past year, denser in recent
 * weeks, so every dashboard period and chart range has data to show.
 * The two newest shipments mirror the design exactly (one unpaid).
 */
export const buildDemoShipments = (now = new Date()): DemoShipmentSeed[] => {
  const seeds: DemoShipmentSeed[] = [];

  const daysAgoList = [
    // Last 7 days
    0, 1, 2, 3, 5, 6,
    // Rest of the last month
    9, 12, 15, 18, 22, 26, 29,
    // Rest of the year, growing toward the present
    35, 45, 58, 70, 84, 100, 120, 140, 165, 190, 220, 250, 290, 330, 360,
  ];

  daysAgoList.forEach((daysAgo, index) => {
    const isExport = index % 3 !== 2;
    const [foreignCity, foreignCode] = pick(FOREIGN);
    const international = index % 2 === 1;
    const delivery = international
      ? { city: foreignCity, country: foreignCode }
      : { city: pick(LOCAL_CITIES), country: 'NG' };

    seeds.push({
      trackingId: generateTrackingId(),
      sender: pick(SENDERS),
      receiver: pick(RECEIVERS),
      pickupFrom: isExport ? 'Lagos, Nigeria' : delivery.city,
      pickupCountry: isExport ? 'NG' : delivery.country,
      deliveryTo: isExport ? delivery.city : 'Lagos, Nigeria',
      deliveryCountry: isExport ? delivery.country : 'NG',
      amount: randomInt(3, 60) * 1000,
      status: daysAgo > 30 ? ShipmentStatus.DELIVERED : pick(STATUSES),
      type: isExport ? ShipmentType.EXPORT : ShipmentType.IMPORT,
      processingHours: randomInt(4, 49),
      isPaid: true,
      // Spread across the day so buckets are not all at midnight.
      shippedAt: new Date(
        now.getTime() - daysAgo * DAY_MS - randomInt(0, 8) * 60 * 60 * 1000,
      ),
    });
  });

  // Match the two cards shown in the design.
  Object.assign(seeds[0], {
    sender: 'Bunmi Tanny',
    receiver: 'Mercy',
    pickupFrom: 'Lagos, Nigeria',
    pickupCountry: 'NG',
    deliveryTo: 'Oyo Nigeria',
    deliveryCountry: 'NG',
    amount: 3000,
    status: ShipmentStatus.IN_TRANSIT,
    type: ShipmentType.EXPORT,
    processingHours: 10,
    isPaid: true,
    shippedAt: now,
  });
  Object.assign(seeds[1], {
    sender: 'Bunmi Tanny',
    receiver: 'Mercy',
    pickupFrom: 'Lagos, Nigeria',
    pickupCountry: 'NG',
    deliveryTo: 'Oyo Nigeria',
    deliveryCountry: 'NG',
    amount: 3000,
    status: ShipmentStatus.DELAYED,
    type: ShipmentType.EXPORT,
    processingHours: 10,
    isPaid: false,
    shippedAt: new Date(now.getTime() - 60 * 60 * 1000),
  });

  return seeds;
};
