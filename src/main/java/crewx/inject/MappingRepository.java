package crewx.inject;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/** Loads every runtime mapping from the repository's single, versioned JSON document. */
final class MappingRepository {
    static final String DOCUMENT_URL = "https://raw.githubusercontent.com/4everdies/CrewX-Injector/main/src/main/resources/crewx/inject/mappings.json";
    private static final String DOCUMENT_FORMAT = "crewx-mappings/1";
    private static final int MAX_DOCUMENT_BYTES = 32 * 1024 * 1024;
    private static volatile JsonObject document;

    private MappingRepository() { }

    static JsonObject profile(String name) {
        JsonObject profiles = root().getAsJsonObject("profiles");
        JsonElement element = profiles == null ? null : profiles.get(name);
        return element != null && element.isJsonObject() ? element.getAsJsonObject() : null;
    }

    static InputStream openResource(String name) throws IOException {
        // A payload and its runtime transformer must use the same mapping snapshot.
        // Explicit document overrides still take precedence for development.
        if (System.getProperty("crewx.mappings.document") == null
                && !Boolean.getBoolean("crewx.mappings.remote")) {
            InputStream bundled = MappingRepository.class.getResourceAsStream(name);
            if (bundled != null) return bundled;
        }
        JsonObject profiles = root().getAsJsonObject("profiles");
        if (profiles != null) {
            for (Map.Entry<String, JsonElement> profile : profiles.entrySet()) {
                if (!profile.getValue().isJsonObject()) continue;
                JsonElement resourcesElement = profile.getValue().getAsJsonObject().get("resources");
                if (resourcesElement == null || !resourcesElement.isJsonObject()) continue;
                JsonElement resource = resourcesElement.getAsJsonObject().get(name);
                if (resource != null && resource.isJsonPrimitive()) {
                    return new ByteArrayInputStream(resource.getAsString()
                            .getBytes(StandardCharsets.UTF_8));
                }
            }
        }
        InputStream fallback = MappingRepository.class.getResourceAsStream(name);
        if (fallback == null) throw new IOException("Mapping resource missing: " + name);
        return fallback;
    }

    private static JsonObject root() {
        JsonObject current = document;
        if (current == null) {
            synchronized (MappingRepository.class) {
                current = document;
                if (current == null) {
                    current = loadConfiguredDocument();
                    if (current == null && Boolean.getBoolean("crewx.mappings.remote")) {
                        current = loadRemote();
                    }
                    if (current == null) current = loadBundled();
                    if (current == null) {
                        current = new JsonObject();
                        current.addProperty("format", DOCUMENT_FORMAT);
                        current.add("profiles", new JsonObject());
                    }
                    document = current;
                }
            }
        }
        return current;
    }

    private static JsonObject loadConfiguredDocument() {
        String configured = System.getProperty("crewx.mappings.document");
        if (configured == null || configured.length() == 0) return null;
        try (InputStream input = new java.io.FileInputStream(configured)) {
            JsonObject parsed = parse(input);
            return valid(parsed) ? parsed : null;
        } catch (Exception ignored) {
            return null;
        }
    }

    private static JsonObject loadRemote() {
        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection) new URL(DOCUMENT_URL).openConnection();
            connection.setConnectTimeout(3500);
            connection.setReadTimeout(7000);
            connection.setUseCaches(false);
            connection.setRequestProperty("Accept", "application/json");
            connection.setRequestProperty("User-Agent", "CrewX-Injector-Mappings/1");
            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) return null;
            try (InputStream input = connection.getInputStream()) {
                JsonObject parsed = parse(input);
                if (valid(parsed)) return parsed;
            }
        } catch (Exception ignored) {
            // Offline launches continue with the mapping snapshot packaged in the client.
        } finally {
            if (connection != null) connection.disconnect();
        }
        return null;
    }

    private static JsonObject loadBundled() {
        try (InputStream input = MappingRepository.class.getResourceAsStream("mappings.json")) {
            if (input == null) return null;
            JsonObject parsed = parse(input);
            return valid(parsed) ? parsed : null;
        } catch (Exception ignored) {
            return null;
        }
    }

    private static JsonObject parse(InputStream input) throws IOException {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int total = 0;
        int count;
        while ((count = input.read(buffer)) != -1) {
            total += count;
            if (total > MAX_DOCUMENT_BYTES) throw new IOException("Mappings JSON is too large");
            bytes.write(buffer, 0, count);
        }
        JsonElement parsed = new JsonParser().parse(new InputStreamReader(
                new ByteArrayInputStream(bytes.toByteArray()), StandardCharsets.UTF_8));
        return parsed != null && parsed.isJsonObject() ? parsed.getAsJsonObject() : null;
    }

    private static boolean valid(JsonObject value) {
        if (value == null || !"crewx-mappings/1".equals(string(value, "format"))) return false;
        JsonElement profiles = value.get("profiles");
        if (profiles == null || !profiles.isJsonObject()) return false;
        JsonObject allProfiles = profiles.getAsJsonObject();
        return hasResource(allProfiles, "notch", "notch-joined.srg")
                && hasResource(allProfiles, "notch", "notch-methods.csv")
                && hasResource(allProfiles, "notch", "notch-fields.csv")
                && hasResource(allProfiles, "ornithe", "ornithe-joined.srg")
                && hasResource(allProfiles, "ornithe", "ornithe-intermediary.tiny")
                && hasResource(allProfiles, "cheatbreaker", "cheatbreaker189.tiny");
    }

    private static boolean hasResource(JsonObject profiles, String profileName, String resourceName) {
        JsonElement profile = profiles.get(profileName);
        if (profile == null || !profile.isJsonObject()) return false;
        JsonElement resources = profile.getAsJsonObject().get("resources");
        if (resources == null || !resources.isJsonObject()) return false;
        JsonElement resource = resources.getAsJsonObject().get(resourceName);
        return resource != null && resource.isJsonPrimitive();
    }

    private static String string(JsonObject object, String key) {
        JsonElement value = object.get(key);
        return value == null || !value.isJsonPrimitive() ? null : value.getAsString();
    }
}
