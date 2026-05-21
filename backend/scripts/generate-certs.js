/**
 * Generates a self-signed SSL certificate for development and prints
 * the SHA-256 fingerprint to use in Flutter SSL pinning.
 *
 * Usage: node backend/scripts/generate-certs.js
 * Requires: openssl installed on system
 */

import { execSync } from 'child_process';
import { createHash } from 'crypto';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const certDir = path.join(__dirname, '..', 'certs');

fs.mkdirSync(certDir, { recursive: true });

const keyPath = path.join(certDir, 'server.key');
const crtPath = path.join(certDir, 'server.crt');
const derPath = path.join(certDir, 'server.der');

console.log('Generating self-signed certificate...');

execSync(
    `openssl req -x509 -newkey rsa:2048 -keyout "${keyPath}" -out "${crtPath}" -days 365 -nodes ` +
    `-subj "/CN=localhost/O=DemoApp/C=IN"`,
    { stdio: 'inherit' }
);

// Export DER (binary) for fingerprint calculation
execSync(`openssl x509 -in "${crtPath}" -outform DER -out "${derPath}"`);

const der = fs.readFileSync(derPath);
const sha256 = createHash('sha256').update(der).digest('base64');

console.log('\n✅ Certificate generated in backend/certs/');
console.log('\n--- Flutter SSL Pinning Fingerprint (SHA-256 base64) ---');
console.log(sha256);
console.log('\nAdd this to your Flutter http client (e.g. dio or http+dart:io):');
console.log(`
  // Using the 'http' package with SecurityContext:
  final context = SecurityContext();
  final certBytes = await rootBundle.load('assets/certs/server.crt');
  context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());

  // OR use the SHA-256 fingerprint with a custom BadCertificateCallback:
  // pinned SHA-256 (base64): ${sha256}
`);
