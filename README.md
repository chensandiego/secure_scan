# secure_scan

that chains Syft → Grype → Trivy → Cosign in one command.
Make it executable
chmod +x secure_scan.sh

Example usage

Just scan (no signing):

./secure_scan.sh my-image:latest

Scan + sign + verify:

./secure_scan.sh my-image:latest --sign

scan_reports_YYYYMMDD_HHMMSS/

sbom.json & sbom.txt → SBOM from Syft

grype.json & grype.txt → Vulnerability scan from Grype

trivy.json & trivy.txt → Vulnerability & misconfiguration scan from Trivy

Optional signing & verification results from Cosign

How it works

build_image → Builds your container image with Docker-in-Docker.

scan_image →

Runs Syft → generates SBOM

Runs Grype → vulnerability scan from SBOM

Runs Trivy → vulnerability + misconfig scan

Saves all reports as GitLab CI artifacts

sign_image (only on main branch) →

Uses Cosign to sign and verify the image

Keys come from GitLab CI/CD variables:

COSIGN_KEY → base64 private key or inline private key

COSIGN_PUB → base64 public key or inline public key

push_image → Pushes signed image to your GitLab Container Registry

Setup in GitLab

Go to Settings → CI/CD → Variables

Add:

COSIGN_KEY → contents of cosign.key

COSIGN_PUB → contents of cosign.pub

CI_REGISTRY_USER → GitLab registry username

CI_REGISTRY_PASSWORD → GitLab registry token/password
