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
