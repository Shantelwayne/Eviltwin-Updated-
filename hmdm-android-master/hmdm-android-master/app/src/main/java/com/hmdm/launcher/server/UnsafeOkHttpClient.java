package com.hmdm.launcher.server;

import com.hmdm.launcher.BuildConfig;
import com.hmdm.launcher.Const;

import java.security.cert.CertificateException;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import okhttp3.OkHttpClient;

public class UnsafeOkHttpClient {

    /**
     * Returns an OkHttpClient that bypasses all SSL certificate validation.
     *
     * SECURITY WARNING: This method completely disables TLS certificate verification,
     * making the connection vulnerable to Man-In-The-Middle attacks.
     * It is ONLY permitted when TRUST_ANY_CERTIFICATE=true AND the build is a debug
     * build. It will throw an IllegalStateException if called in a release build,
     * regardless of the TRUST_ANY_CERTIFICATE flag.
     */
    public static OkHttpClient getUnsafeOkHttpClient() {
        // Hard guard: never allow cert bypass in release builds
        if (!BuildConfig.DEBUG) {
            throw new IllegalStateException(
                "UnsafeOkHttpClient must not be used in release builds. " +
                "Set TRUST_ANY_CERTIFICATE=false and use a properly signed certificate."
            );
        }

        try {
            // Create a trust manager that does not validate certificate chains
            final TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    @Override
                    public void checkClientTrusted(java.security.cert.X509Certificate[] chain,
                                                   String authType) throws CertificateException {
                        // Intentionally empty: trusts all client certs (debug only)
                    }

                    @Override
                    public void checkServerTrusted(java.security.cert.X509Certificate[] chain,
                                                   String authType) throws CertificateException {
                        // Intentionally empty: trusts all server certs (debug only)
                    }

                    @Override
                    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                        return new java.security.cert.X509Certificate[]{};
                    }
                }
            };

            final SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

            final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

            OkHttpClient.Builder builder = new OkHttpClient.Builder()
                    .connectTimeout(Const.CONNECTION_TIMEOUT, TimeUnit.MILLISECONDS)
                    .readTimeout(Const.CONNECTION_TIMEOUT, TimeUnit.MILLISECONDS)
                    .writeTimeout(Const.CONNECTION_TIMEOUT, TimeUnit.MILLISECONDS);

            builder.sslSocketFactory(sslSocketFactory, (X509TrustManager) trustAllCerts[0]);
            builder.hostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    // Intentionally returns true: skips hostname check (debug only)
                    return true;
                }
            });

            return builder.build();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
