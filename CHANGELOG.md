# 1.0.0
 - Support Mixin for adding API-compatibility with the CATrustedFingerprintSupport introduced in Logstash 8.x.
   When a plugin includes this support adapter, and the plugin is run on a version of Logstash that does not
   provide an implementation, the plugin operates as normal but rejects explicit attempts to use
   the `ca_trusted_fingerprint` option. 
