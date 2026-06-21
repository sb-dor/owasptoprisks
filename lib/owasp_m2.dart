// OWASP Mobile Top 10 - M2: Inadequate Supply Chain Security
//
// Demonstrates risks related to third party dependencies.
//
// Modern applications rely heavily on external packages. A package may
// appear trustworthy, but it can depend on dozens of other packages that
// developers never review directly.
//
// Real incidents such as Event-Stream, Node IPC, and Log4Shell showed that
// attackers can abuse dependency chains, compromised maintainers, or
// vulnerable libraries to distribute malicious code.
//
// Before adding a dependency:
// - Verify the maintainer and project activity.
// - Review package popularity and community trust.
// - Check transitive dependencies.
// - Lock dependency versions when possible.
// - Keep dependencies updated and monitor security advisories.
//
// A package is not automatically safe just because it is popular.

// more info in this youtube video: https://youtu.be/7rFckp0ObQw?si=8jV6tdNQNNNcuP8T
