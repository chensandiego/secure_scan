#!/bin/bash
# Usage: ./secure_scan.sh <image-name> [--sign]
# Example: ./secure_scan.sh my-image:latest --sign

set -e

IMAGE="$1"
SIGN="$2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_DIR="scan_reports_$TIMESTAMP"

if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <image-name> [--sign]"
  exit 1
fi

mkdir -p "$REPORT_DIR"

echo "🔍 [1/5] Generating SBOM with Syft..."
syft "$IMAGE" -o json > "$REPORT_DIR/sbom.json"
syft "$IMAGE" -o table > "$REPORT_DIR/sbom.txt"

echo "🛡 [2/5] Scanning vulnerabilities with Grype..."
grype sbom:"$REPORT_DIR/sbom.json" -o json > "$REPORT_DIR/grype.json"
grype sbom:"$REPORT_DIR/sbom.json" -o table > "$REPORT_DIR/grype.txt"

echo "🛡 [3/5] Scanning vulnerabilities + misconfigurations with Trivy..."
trivy image "$IMAGE" --format json --output "$REPORT_DIR/trivy.json"
trivy image "$IMAGE" --format table --output "$REPORT_DIR/trivy.txt"

if [ "$SIGN" == "--sign" ]; then
  echo "🔏 [4/5] Signing image with Cosign..."
  if [ ! -f cosign.key ]; then
    echo "No cosign.key found. Generating new key pair..."
    cosign generate-key-pair
  fi
  cosign sign --key cosign.key "$IMAGE"
fi

if [ "$SIGN" == "--sign" ]; then
  echo "✅ [5/5] Verifying image signature..."
  cosign verify --key cosign.pub "$IMAGE"
fi

echo "📁 Reports saved in: $REPORT_DIR"
echo "✅ Done."
