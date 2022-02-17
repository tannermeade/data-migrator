part of appwrite.models;

/// Project
class Project implements Model {
    /// Project ID.
    final String $id;
    /// Project name.
    final String name;
    /// Project description.
    final String description;
    /// Project team ID.
    final String teamId;
    /// Project logo file ID.
    final String logo;
    /// Project website URL.
    final String url;
    /// Company legal name.
    final String legalName;
    /// Country code in [ISO 3166-1](http://en.wikipedia.org/wiki/ISO_3166-1) two-character format.
    final String legalCountry;
    /// State name.
    final String legalState;
    /// City name.
    final String legalCity;
    /// Company Address.
    final String legalAddress;
    /// Company Tax ID.
    final String legalTaxId;
    /// Max users allowed. 0 is unlimited.
    final int authLimit;
    /// List of Platforms.
    final List<Platform> platforms;
    /// List of Webhooks.
    final List<Webhook> webhooks;
    /// List of API Keys.
    final List<Key> keys;
    /// List of Domains.
    final List<Domain> domains;
    /// Amazon OAuth app ID.
    final String providerAmazonAppid;
    /// Amazon OAuth secret ID.
    final String providerAmazonSecret;
    /// Apple OAuth app ID.
    final String providerAppleAppid;
    /// Apple OAuth secret ID.
    final String providerAppleSecret;
    /// BitBucket OAuth app ID.
    final String providerBitbucketAppid;
    /// BitBucket OAuth secret ID.
    final String providerBitbucketSecret;
    /// Bitly OAuth app ID.
    final String providerBitlyAppid;
    /// Bitly OAuth secret ID.
    final String providerBitlySecret;
    /// Box OAuth app ID.
    final String providerBoxAppid;
    /// Box OAuth secret ID.
    final String providerBoxSecret;
    /// Discord OAuth app ID.
    final String providerDiscordAppid;
    /// Discord OAuth secret ID.
    final String providerDiscordSecret;
    /// Dropbox OAuth app ID.
    final String providerDropboxAppid;
    /// Dropbox OAuth secret ID.
    final String providerDropboxSecret;
    /// Facebook OAuth app ID.
    final String providerFacebookAppid;
    /// Facebook OAuth secret ID.
    final String providerFacebookSecret;
    /// GitHub OAuth app ID.
    final String providerGithubAppid;
    /// GitHub OAuth secret ID.
    final String providerGithubSecret;
    /// GitLab OAuth app ID.
    final String providerGitlabAppid;
    /// GitLab OAuth secret ID.
    final String providerGitlabSecret;
    /// Google OAuth app ID.
    final String providerGoogleAppid;
    /// Google OAuth secret ID.
    final String providerGoogleSecret;
    /// LinkedIn OAuth app ID.
    final String providerLinkedinAppid;
    /// LinkedIn OAuth secret ID.
    final String providerLinkedinSecret;
    /// Microsoft OAuth app ID.
    final String providerMicrosoftAppid;
    /// Microsoft OAuth secret ID.
    final String providerMicrosoftSecret;
    /// PayPal OAuth app ID.
    final String providerPaypalAppid;
    /// PayPal OAuth secret ID.
    final String providerPaypalSecret;
    /// PayPal OAuth app ID.
    final String providerPaypalSandboxAppid;
    /// PayPal OAuth secret ID.
    final String providerPaypalSandboxSecret;
    /// Salesforce OAuth app ID.
    final String providerSalesforceAppid;
    /// Salesforce OAuth secret ID.
    final String providerSalesforceSecret;
    /// Slack OAuth app ID.
    final String providerSlackAppid;
    /// Slack OAuth secret ID.
    final String providerSlackSecret;
    /// Spotify OAuth app ID.
    final String providerSpotifyAppid;
    /// Spotify OAuth secret ID.
    final String providerSpotifySecret;
    /// Tradeshift OAuth app ID.
    final String providerTradeshiftAppid;
    /// Tradeshift OAuth secret ID.
    final String providerTradeshiftSecret;
    /// Tradeshift OAuth app ID.
    final String providerTradeshiftBoxAppid;
    /// Tradeshift OAuth secret ID.
    final String providerTradeshiftBoxSecret;
    /// Twitch OAuth app ID.
    final String providerTwitchAppid;
    /// Twitch OAuth secret ID.
    final String providerTwitchSecret;
    /// VK OAuth app ID.
    final String providerVkAppid;
    /// VK OAuth secret ID.
    final String providerVkSecret;
    /// Yahoo OAuth app ID.
    final String providerYahooAppid;
    /// Yahoo OAuth secret ID.
    final String providerYahooSecret;
    /// Yammer OAuth app ID.
    final String providerYammerAppid;
    /// Yammer OAuth secret ID.
    final String providerYammerSecret;
    /// Yandex OAuth app ID.
    final String providerYandexAppid;
    /// Yandex OAuth secret ID.
    final String providerYandexSecret;
    /// WordPress OAuth app ID.
    final String providerWordpressAppid;
    /// WordPress OAuth secret ID.
    final String providerWordpressSecret;
    /// Mock OAuth app ID.
    final String providerMockAppid;
    /// Mock OAuth secret ID.
    final String providerMockSecret;
    /// Email/Password auth method status
    final bool authEmailPassword;
    /// Magic URL auth method status
    final bool authUsersAuthMagicURL;
    /// Anonymous auth method status
    final bool authAnonymous;
    /// Invites auth method status
    final bool authInvites;
    /// JWT auth method status
    final bool authJWT;
    /// Phone auth method status
    final bool authPhone;
    /// Account service status
    final bool serviceStatusForAccount;
    /// Avatars service status
    final bool serviceStatusForAvatars;
    /// Database service status
    final bool serviceStatusForDatabase;
    /// Locale service status
    final bool serviceStatusForLocale;
    /// Health service status
    final bool serviceStatusForHealth;
    /// Storage service status
    final bool serviceStatusForStorage;
    /// Teams service status
    final bool serviceStatusForTeams;
    /// Users service status
    final bool serviceStatusForUsers;
    /// Functions service status
    final bool serviceStatusForFunctions;

    Project({
        required this.$id,
        required this.name,
        required this.description,
        required this.teamId,
        required this.logo,
        required this.url,
        required this.legalName,
        required this.legalCountry,
        required this.legalState,
        required this.legalCity,
        required this.legalAddress,
        required this.legalTaxId,
        required this.authLimit,
        required this.platforms,
        required this.webhooks,
        required this.keys,
        required this.domains,
        required this.providerAmazonAppid,
        required this.providerAmazonSecret,
        required this.providerAppleAppid,
        required this.providerAppleSecret,
        required this.providerBitbucketAppid,
        required this.providerBitbucketSecret,
        required this.providerBitlyAppid,
        required this.providerBitlySecret,
        required this.providerBoxAppid,
        required this.providerBoxSecret,
        required this.providerDiscordAppid,
        required this.providerDiscordSecret,
        required this.providerDropboxAppid,
        required this.providerDropboxSecret,
        required this.providerFacebookAppid,
        required this.providerFacebookSecret,
        required this.providerGithubAppid,
        required this.providerGithubSecret,
        required this.providerGitlabAppid,
        required this.providerGitlabSecret,
        required this.providerGoogleAppid,
        required this.providerGoogleSecret,
        required this.providerLinkedinAppid,
        required this.providerLinkedinSecret,
        required this.providerMicrosoftAppid,
        required this.providerMicrosoftSecret,
        required this.providerPaypalAppid,
        required this.providerPaypalSecret,
        required this.providerPaypalSandboxAppid,
        required this.providerPaypalSandboxSecret,
        required this.providerSalesforceAppid,
        required this.providerSalesforceSecret,
        required this.providerSlackAppid,
        required this.providerSlackSecret,
        required this.providerSpotifyAppid,
        required this.providerSpotifySecret,
        required this.providerTradeshiftAppid,
        required this.providerTradeshiftSecret,
        required this.providerTradeshiftBoxAppid,
        required this.providerTradeshiftBoxSecret,
        required this.providerTwitchAppid,
        required this.providerTwitchSecret,
        required this.providerVkAppid,
        required this.providerVkSecret,
        required this.providerYahooAppid,
        required this.providerYahooSecret,
        required this.providerYammerAppid,
        required this.providerYammerSecret,
        required this.providerYandexAppid,
        required this.providerYandexSecret,
        required this.providerWordpressAppid,
        required this.providerWordpressSecret,
        required this.providerMockAppid,
        required this.providerMockSecret,
        required this.authEmailPassword,
        required this.authUsersAuthMagicURL,
        required this.authAnonymous,
        required this.authInvites,
        required this.authJWT,
        required this.authPhone,
        required this.serviceStatusForAccount,
        required this.serviceStatusForAvatars,
        required this.serviceStatusForDatabase,
        required this.serviceStatusForLocale,
        required this.serviceStatusForHealth,
        required this.serviceStatusForStorage,
        required this.serviceStatusForTeams,
        required this.serviceStatusForUsers,
        required this.serviceStatusForFunctions,
    });

    factory Project.fromMap(Map<String, dynamic> map) {
        return Project(
            $id: map['\$id'].toString(),
            name: map['name'].toString(),
            description: map['description'].toString(),
            teamId: map['teamId'].toString(),
            logo: map['logo'].toString(),
            url: map['url'].toString(),
            legalName: map['legalName'].toString(),
            legalCountry: map['legalCountry'].toString(),
            legalState: map['legalState'].toString(),
            legalCity: map['legalCity'].toString(),
            legalAddress: map['legalAddress'].toString(),
            legalTaxId: map['legalTaxId'].toString(),
            authLimit: map['authLimit'],
            platforms: List<Platform>.from(map['platforms'].map((p) => Platform.fromMap(p))),
            webhooks: List<Webhook>.from(map['webhooks'].map((p) => Webhook.fromMap(p))),
            keys: List<Key>.from(map['keys'].map((p) => Key.fromMap(p))),
            domains: List<Domain>.from(map['domains'].map((p) => Domain.fromMap(p))),
            providerAmazonAppid: map['providerAmazonAppid'].toString(),
            providerAmazonSecret: map['providerAmazonSecret'].toString(),
            providerAppleAppid: map['providerAppleAppid'].toString(),
            providerAppleSecret: map['providerAppleSecret'].toString(),
            providerBitbucketAppid: map['providerBitbucketAppid'].toString(),
            providerBitbucketSecret: map['providerBitbucketSecret'].toString(),
            providerBitlyAppid: map['providerBitlyAppid'].toString(),
            providerBitlySecret: map['providerBitlySecret'].toString(),
            providerBoxAppid: map['providerBoxAppid'].toString(),
            providerBoxSecret: map['providerBoxSecret'].toString(),
            providerDiscordAppid: map['providerDiscordAppid'].toString(),
            providerDiscordSecret: map['providerDiscordSecret'].toString(),
            providerDropboxAppid: map['providerDropboxAppid'].toString(),
            providerDropboxSecret: map['providerDropboxSecret'].toString(),
            providerFacebookAppid: map['providerFacebookAppid'].toString(),
            providerFacebookSecret: map['providerFacebookSecret'].toString(),
            providerGithubAppid: map['providerGithubAppid'].toString(),
            providerGithubSecret: map['providerGithubSecret'].toString(),
            providerGitlabAppid: map['providerGitlabAppid'].toString(),
            providerGitlabSecret: map['providerGitlabSecret'].toString(),
            providerGoogleAppid: map['providerGoogleAppid'].toString(),
            providerGoogleSecret: map['providerGoogleSecret'].toString(),
            providerLinkedinAppid: map['providerLinkedinAppid'].toString(),
            providerLinkedinSecret: map['providerLinkedinSecret'].toString(),
            providerMicrosoftAppid: map['providerMicrosoftAppid'].toString(),
            providerMicrosoftSecret: map['providerMicrosoftSecret'].toString(),
            providerPaypalAppid: map['providerPaypalAppid'].toString(),
            providerPaypalSecret: map['providerPaypalSecret'].toString(),
            providerPaypalSandboxAppid: map['providerPaypalSandboxAppid'].toString(),
            providerPaypalSandboxSecret: map['providerPaypalSandboxSecret'].toString(),
            providerSalesforceAppid: map['providerSalesforceAppid'].toString(),
            providerSalesforceSecret: map['providerSalesforceSecret'].toString(),
            providerSlackAppid: map['providerSlackAppid'].toString(),
            providerSlackSecret: map['providerSlackSecret'].toString(),
            providerSpotifyAppid: map['providerSpotifyAppid'].toString(),
            providerSpotifySecret: map['providerSpotifySecret'].toString(),
            providerTradeshiftAppid: map['providerTradeshiftAppid'].toString(),
            providerTradeshiftSecret: map['providerTradeshiftSecret'].toString(),
            providerTradeshiftBoxAppid: map['providerTradeshiftBoxAppid'].toString(),
            providerTradeshiftBoxSecret: map['providerTradeshiftBoxSecret'].toString(),
            providerTwitchAppid: map['providerTwitchAppid'].toString(),
            providerTwitchSecret: map['providerTwitchSecret'].toString(),
            providerVkAppid: map['providerVkAppid'].toString(),
            providerVkSecret: map['providerVkSecret'].toString(),
            providerYahooAppid: map['providerYahooAppid'].toString(),
            providerYahooSecret: map['providerYahooSecret'].toString(),
            providerYammerAppid: map['providerYammerAppid'].toString(),
            providerYammerSecret: map['providerYammerSecret'].toString(),
            providerYandexAppid: map['providerYandexAppid'].toString(),
            providerYandexSecret: map['providerYandexSecret'].toString(),
            providerWordpressAppid: map['providerWordpressAppid'].toString(),
            providerWordpressSecret: map['providerWordpressSecret'].toString(),
            providerMockAppid: map['providerMockAppid'].toString(),
            providerMockSecret: map['providerMockSecret'].toString(),
            authEmailPassword: map['authEmailPassword'],
            authUsersAuthMagicURL: map['authUsersAuthMagicURL'],
            authAnonymous: map['authAnonymous'],
            authInvites: map['authInvites'],
            authJWT: map['authJWT'],
            authPhone: map['authPhone'],
            serviceStatusForAccount: map['serviceStatusForAccount'],
            serviceStatusForAvatars: map['serviceStatusForAvatars'],
            serviceStatusForDatabase: map['serviceStatusForDatabase'],
            serviceStatusForLocale: map['serviceStatusForLocale'],
            serviceStatusForHealth: map['serviceStatusForHealth'],
            serviceStatusForStorage: map['serviceStatusForStorage'],
            serviceStatusForTeams: map['serviceStatusForTeams'],
            serviceStatusForUsers: map['serviceStatusForUsers'],
            serviceStatusForFunctions: map['serviceStatusForFunctions'],
        );
    }

    @override
    Map<String, dynamic> toMap() {
        return {
            "\$id": $id,
            "name": name,
            "description": description,
            "teamId": teamId,
            "logo": logo,
            "url": url,
            "legalName": legalName,
            "legalCountry": legalCountry,
            "legalState": legalState,
            "legalCity": legalCity,
            "legalAddress": legalAddress,
            "legalTaxId": legalTaxId,
            "authLimit": authLimit,
            "platforms": platforms.map((p) => p.toMap()),
            "webhooks": webhooks.map((p) => p.toMap()),
            "keys": keys.map((p) => p.toMap()),
            "domains": domains.map((p) => p.toMap()),
            "providerAmazonAppid": providerAmazonAppid,
            "providerAmazonSecret": providerAmazonSecret,
            "providerAppleAppid": providerAppleAppid,
            "providerAppleSecret": providerAppleSecret,
            "providerBitbucketAppid": providerBitbucketAppid,
            "providerBitbucketSecret": providerBitbucketSecret,
            "providerBitlyAppid": providerBitlyAppid,
            "providerBitlySecret": providerBitlySecret,
            "providerBoxAppid": providerBoxAppid,
            "providerBoxSecret": providerBoxSecret,
            "providerDiscordAppid": providerDiscordAppid,
            "providerDiscordSecret": providerDiscordSecret,
            "providerDropboxAppid": providerDropboxAppid,
            "providerDropboxSecret": providerDropboxSecret,
            "providerFacebookAppid": providerFacebookAppid,
            "providerFacebookSecret": providerFacebookSecret,
            "providerGithubAppid": providerGithubAppid,
            "providerGithubSecret": providerGithubSecret,
            "providerGitlabAppid": providerGitlabAppid,
            "providerGitlabSecret": providerGitlabSecret,
            "providerGoogleAppid": providerGoogleAppid,
            "providerGoogleSecret": providerGoogleSecret,
            "providerLinkedinAppid": providerLinkedinAppid,
            "providerLinkedinSecret": providerLinkedinSecret,
            "providerMicrosoftAppid": providerMicrosoftAppid,
            "providerMicrosoftSecret": providerMicrosoftSecret,
            "providerPaypalAppid": providerPaypalAppid,
            "providerPaypalSecret": providerPaypalSecret,
            "providerPaypalSandboxAppid": providerPaypalSandboxAppid,
            "providerPaypalSandboxSecret": providerPaypalSandboxSecret,
            "providerSalesforceAppid": providerSalesforceAppid,
            "providerSalesforceSecret": providerSalesforceSecret,
            "providerSlackAppid": providerSlackAppid,
            "providerSlackSecret": providerSlackSecret,
            "providerSpotifyAppid": providerSpotifyAppid,
            "providerSpotifySecret": providerSpotifySecret,
            "providerTradeshiftAppid": providerTradeshiftAppid,
            "providerTradeshiftSecret": providerTradeshiftSecret,
            "providerTradeshiftBoxAppid": providerTradeshiftBoxAppid,
            "providerTradeshiftBoxSecret": providerTradeshiftBoxSecret,
            "providerTwitchAppid": providerTwitchAppid,
            "providerTwitchSecret": providerTwitchSecret,
            "providerVkAppid": providerVkAppid,
            "providerVkSecret": providerVkSecret,
            "providerYahooAppid": providerYahooAppid,
            "providerYahooSecret": providerYahooSecret,
            "providerYammerAppid": providerYammerAppid,
            "providerYammerSecret": providerYammerSecret,
            "providerYandexAppid": providerYandexAppid,
            "providerYandexSecret": providerYandexSecret,
            "providerWordpressAppid": providerWordpressAppid,
            "providerWordpressSecret": providerWordpressSecret,
            "providerMockAppid": providerMockAppid,
            "providerMockSecret": providerMockSecret,
            "authEmailPassword": authEmailPassword,
            "authUsersAuthMagicURL": authUsersAuthMagicURL,
            "authAnonymous": authAnonymous,
            "authInvites": authInvites,
            "authJWT": authJWT,
            "authPhone": authPhone,
            "serviceStatusForAccount": serviceStatusForAccount,
            "serviceStatusForAvatars": serviceStatusForAvatars,
            "serviceStatusForDatabase": serviceStatusForDatabase,
            "serviceStatusForLocale": serviceStatusForLocale,
            "serviceStatusForHealth": serviceStatusForHealth,
            "serviceStatusForStorage": serviceStatusForStorage,
            "serviceStatusForTeams": serviceStatusForTeams,
            "serviceStatusForUsers": serviceStatusForUsers,
            "serviceStatusForFunctions": serviceStatusForFunctions,
        };
    }
}
