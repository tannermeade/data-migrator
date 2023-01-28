part of appwrite;

    /// The Project service allows you to manage all the projects in your Appwrite
    /// server.
class Projects extends Service {
    Projects(super.client);

    /// List Projects
     Future<models.ProjectList> list({List<String>? queries, String? search}) async {
        const String path = '/projects';

        final Map<String, dynamic> params = {
            'queries': queries,
            'search': search,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.ProjectList.fromMap(res.data);

    }

    /// Create Project
     Future<models.Project> create({required String projectId, required String name, required String teamId, String? description, String? logo, String? url, String? legalName, String? legalCountry, String? legalState, String? legalCity, String? legalAddress, String? legalTaxId}) async {
        const String path = '/projects';

        final Map<String, dynamic> params = {
            'projectId': projectId,
            'name': name,
            'teamId': teamId,
            'description': description,
            'logo': logo,
            'url': url,
            'legalName': legalName,
            'legalCountry': legalCountry,
            'legalState': legalState,
            'legalCity': legalCity,
            'legalAddress': legalAddress,
            'legalTaxId': legalTaxId,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.post, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// Get Project
     Future<models.Project> get({required String projectId}) async {
        final String path = '/projects/{projectId}'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// Update Project
     Future<models.Project> update({required String projectId, required String name, String? description, String? logo, String? url, String? legalName, String? legalCountry, String? legalState, String? legalCity, String? legalAddress, String? legalTaxId}) async {
        final String path = '/projects/{projectId}'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'name': name,
            'description': description,
            'logo': logo,
            'url': url,
            'legalName': legalName,
            'legalCountry': legalCountry,
            'legalState': legalState,
            'legalCity': legalCity,
            'legalAddress': legalAddress,
            'legalTaxId': legalTaxId,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// Delete Project
     Future delete({required String projectId, required String password}) async {
        final String path = '/projects/{projectId}'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'password': password,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.delete, path: path, params: params, headers: headers);

        return  res.data;

    }

    /// Update Project users limit
     Future<models.Project> updateAuthLimit({required String projectId, required int limit}) async {
        final String path = '/projects/{projectId}/auth/limit'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'limit': limit,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// Update Project auth method status. Use this endpoint to enable or disable a given auth method for this project.
     Future<models.Project> updateAuthStatus({required String projectId, required String method, required bool status}) async {
        final String path = '/projects/{projectId}/auth/{method}'.replaceAll('{projectId}', projectId).replaceAll('{method}', method);

        final Map<String, dynamic> params = {
            'status': status,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// List Domains
     Future<models.DomainList> listDomains({required String projectId}) async {
        final String path = '/projects/{projectId}/domains'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.DomainList.fromMap(res.data);

    }

    /// Create Domain
     Future<models.Domain> createDomain({required String projectId, required String domain}) async {
        final String path = '/projects/{projectId}/domains'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'domain': domain,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.post, path: path, params: params, headers: headers);

        return models.Domain.fromMap(res.data);

    }

    /// Get Domain
     Future<models.Domain> getDomain({required String projectId, required String domainId}) async {
        final String path = '/projects/{projectId}/domains/{domainId}'.replaceAll('{projectId}', projectId).replaceAll('{domainId}', domainId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.Domain.fromMap(res.data);

    }

    /// Delete Domain
     Future deleteDomain({required String projectId, required String domainId}) async {
        final String path = '/projects/{projectId}/domains/{domainId}'.replaceAll('{projectId}', projectId).replaceAll('{domainId}', domainId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.delete, path: path, params: params, headers: headers);

        return  res.data;

    }

    /// Update Domain Verification Status
     Future<models.Domain> updateDomainVerification({required String projectId, required String domainId}) async {
        final String path = '/projects/{projectId}/domains/{domainId}/verification'.replaceAll('{projectId}', projectId).replaceAll('{domainId}', domainId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Domain.fromMap(res.data);

    }

    /// List Keys
     Future<models.KeyList> listKeys({required String projectId}) async {
        final String path = '/projects/{projectId}/keys'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.KeyList.fromMap(res.data);

    }

    /// Create Key
     Future<models.Key> createKey({required String projectId, required String name, required List<String> scopes, String? expire}) async {
        final String path = '/projects/{projectId}/keys'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'name': name,
            'scopes': scopes,
            'expire': expire,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.post, path: path, params: params, headers: headers);

        return models.Key.fromMap(res.data);

    }

    /// Get Key
     Future<models.Key> getKey({required String projectId, required String keyId}) async {
        final String path = '/projects/{projectId}/keys/{keyId}'.replaceAll('{projectId}', projectId).replaceAll('{keyId}', keyId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.Key.fromMap(res.data);

    }

    /// Update Key
     Future<models.Key> updateKey({required String projectId, required String keyId, required String name, required List<String> scopes, String? expire}) async {
        final String path = '/projects/{projectId}/keys/{keyId}'.replaceAll('{projectId}', projectId).replaceAll('{keyId}', keyId);

        final Map<String, dynamic> params = {
            'name': name,
            'scopes': scopes,
            'expire': expire,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.put, path: path, params: params, headers: headers);

        return models.Key.fromMap(res.data);

    }

    /// Delete Key
     Future deleteKey({required String projectId, required String keyId}) async {
        final String path = '/projects/{projectId}/keys/{keyId}'.replaceAll('{projectId}', projectId).replaceAll('{keyId}', keyId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.delete, path: path, params: params, headers: headers);

        return  res.data;

    }

    /// Update Project OAuth2
     Future<models.Project> updateOAuth2({required String projectId, required String provider, String? appId, String? secret}) async {
        final String path = '/projects/{projectId}/oauth2'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'provider': provider,
            'appId': appId,
            'secret': secret,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// List Platforms
     Future<models.PlatformList> listPlatforms({required String projectId}) async {
        final String path = '/projects/{projectId}/platforms'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.PlatformList.fromMap(res.data);

    }

    /// Create Platform
     Future<models.Platform> createPlatform({required String projectId, required String type, required String name, String? key, String? store, String? hostname}) async {
        final String path = '/projects/{projectId}/platforms'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'type': type,
            'name': name,
            'key': key,
            'store': store,
            'hostname': hostname,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.post, path: path, params: params, headers: headers);

        return models.Platform.fromMap(res.data);

    }

    /// Get Platform
     Future<models.Platform> getPlatform({required String projectId, required String platformId}) async {
        final String path = '/projects/{projectId}/platforms/{platformId}'.replaceAll('{projectId}', projectId).replaceAll('{platformId}', platformId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.Platform.fromMap(res.data);

    }

    /// Update Platform
     Future<models.Platform> updatePlatform({required String projectId, required String platformId, required String name, String? key, String? store, String? hostname}) async {
        final String path = '/projects/{projectId}/platforms/{platformId}'.replaceAll('{projectId}', projectId).replaceAll('{platformId}', platformId);

        final Map<String, dynamic> params = {
            'name': name,
            'key': key,
            'store': store,
            'hostname': hostname,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.put, path: path, params: params, headers: headers);

        return models.Platform.fromMap(res.data);

    }

    /// Delete Platform
     Future deletePlatform({required String projectId, required String platformId}) async {
        final String path = '/projects/{projectId}/platforms/{platformId}'.replaceAll('{projectId}', projectId).replaceAll('{platformId}', platformId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.delete, path: path, params: params, headers: headers);

        return  res.data;

    }

    /// Update service status
     Future<models.Project> updateServiceStatus({required String projectId, required String service, required bool status}) async {
        final String path = '/projects/{projectId}/service'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'service': service,
            'status': status,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Project.fromMap(res.data);

    }

    /// Get usage stats for a project
     Future<models.UsageProject> getUsage({required String projectId, String? range}) async {
        final String path = '/projects/{projectId}/usage'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'range': range,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.UsageProject.fromMap(res.data);

    }

    /// List Webhooks
     Future<models.WebhookList> listWebhooks({required String projectId}) async {
        final String path = '/projects/{projectId}/webhooks'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.WebhookList.fromMap(res.data);

    }

    /// Create Webhook
     Future<models.Webhook> createWebhook({required String projectId, required String name, required List<String> events, required String url, required bool security, String? httpUser, String? httpPass}) async {
        final String path = '/projects/{projectId}/webhooks'.replaceAll('{projectId}', projectId);

        final Map<String, dynamic> params = {
            'name': name,
            'events': events,
            'url': url,
            'security': security,
            'httpUser': httpUser,
            'httpPass': httpPass,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.post, path: path, params: params, headers: headers);

        return models.Webhook.fromMap(res.data);

    }

    /// Get Webhook
     Future<models.Webhook> getWebhook({required String projectId, required String webhookId}) async {
        final String path = '/projects/{projectId}/webhooks/{webhookId}'.replaceAll('{projectId}', projectId).replaceAll('{webhookId}', webhookId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.get, path: path, params: params, headers: headers);

        return models.Webhook.fromMap(res.data);

    }

    /// Update Webhook
     Future<models.Webhook> updateWebhook({required String projectId, required String webhookId, required String name, required List<String> events, required String url, required bool security, String? httpUser, String? httpPass}) async {
        final String path = '/projects/{projectId}/webhooks/{webhookId}'.replaceAll('{projectId}', projectId).replaceAll('{webhookId}', webhookId);

        final Map<String, dynamic> params = {
            'name': name,
            'events': events,
            'url': url,
            'security': security,
            'httpUser': httpUser,
            'httpPass': httpPass,
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.put, path: path, params: params, headers: headers);

        return models.Webhook.fromMap(res.data);

    }

    /// Delete Webhook
     Future deleteWebhook({required String projectId, required String webhookId}) async {
        final String path = '/projects/{projectId}/webhooks/{webhookId}'.replaceAll('{projectId}', projectId).replaceAll('{webhookId}', webhookId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.delete, path: path, params: params, headers: headers);

        return  res.data;

    }

    /// Update Webhook Signature Key
     Future<models.Webhook> updateWebhookSignature({required String projectId, required String webhookId}) async {
        final String path = '/projects/{projectId}/webhooks/{webhookId}/signature'.replaceAll('{projectId}', projectId).replaceAll('{webhookId}', webhookId);

        final Map<String, dynamic> params = {
        };

        final Map<String, String> headers = {
            'content-type': 'application/json',
        };

        final res = await client.call(HttpMethod.patch, path: path, params: params, headers: headers);

        return models.Webhook.fromMap(res.data);

    }
}