# AWS IoT Certificates

Place your AWS IoT certificates in this directory:

- `certificate.pem.crt` - Your device certificate
- `private.pem.key` - Your private key
- `AmazonRootCA1.pem` - Amazon Root CA certificate

## How to obtain certificates:

1. Go to AWS IoT Console
2. Create a new Thing or use existing
3. Download the certificates and keys
4. Place them in this directory

## Security Note:

These certificates should be kept secure and not committed to version control in production applications. Consider using AWS IoT Device Management or other secure certificate provisioning methods for production deployments.