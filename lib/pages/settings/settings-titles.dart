class SettingsTitle {
   String title;
   String description;
   SettingsTitle({this.title = "", this.description = ""});
}

enum titles {YOUR_ACCOUNT, SECURITY, PRIVACY, NOTIFICATIONS, ACCESSIBILITY, MONETIZATION, ADDITIONAL}

List<SettingsTitle> settingsTitles = [
   SettingsTitle(
    title: "Your Account",
    description: "See information about your account,"
  " download an archive of your data, or learn about"
      " your account deactivation options."
  ),
  SettingsTitle(
      title: "Security and account access",
      description:  "Manage your account's security and keep track of"
          " your account's usage including apps that you have"
          " connected to your account."
  ),
  SettingsTitle(
      title: "Privacy and Safety",
      description: "Manage what information you see and share on Gigachat"
  ),
  SettingsTitle(
      title: "Notifications",
      description: "Select the kinds of notifications you get about"
          " your activities, interests, and recommendations"
  ),
  SettingsTitle(
      title: "Accessibility, display and languages",
      description: "Manage how Gigachat content is displayed to you."
  ),
  SettingsTitle(
      title: "Monetization",
      description: "See how you can make money on Gigachat and manage"
          "your monetization options."
  ),
  SettingsTitle(
      title: "Additional resources",
      description: "Check out other places for helpful information to"
          " learn more about Gigachat products and services."
  ),
];

